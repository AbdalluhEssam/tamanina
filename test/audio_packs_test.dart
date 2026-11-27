import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamanina/core/audio/audio_catalog.dart';
import 'package:tamanina/core/audio/audio_library.dart';
import 'package:tamanina/core/audio/pack_downloader.dart';
import 'package:tamanina/core/settings/settings_repository.dart';
import 'package:tamanina/features/quran/data/services/mushaf_pages.dart';

String _sha(List<int> bytes) => sha256.convert(bytes).toString();

Map<String, Object?> _file(String url, List<int> bytes, {Object? phrases}) => {
  'url': url,
  'sha256': _sha(bytes),
  'bytes': bytes.length,
  'durationMs': 5000,
  'phrases': ?phrases,
};

void main() {
  late Directory temp;
  late HttpServer server;
  final served = <String, List<int>>{};

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('audio_packs');
    served.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) {
      final body = served[request.uri.path];
      if (body == null) {
        request.response.statusCode = 404;
      } else {
        request.response.add(body);
      }
      request.response.close();
    });
  });

  tearDown(() async {
    await server.close(force: true);
    await temp.delete(recursive: true);
  });

  Uri url(String path) => Uri.parse('http://127.0.0.1:${server.port}$path');

  group('catalog', () {
    test(
      'without Remote Config only the bundled adhan and built-in reciters',
      () {
        for (final source in ['', '{}', 'not json', '[]']) {
          final catalog = AudioCatalog.fromJson(source);
          expect(catalog.adhanVoices.map((voice) => voice.id), ['local']);
          expect(catalog.reciters.first.id, defaultReciterId);
          expect(catalog.reciters.length, builtInReciters.length);
        }
      },
    );

    test('keeps valid voices and drops unsafe or incomplete ones', () {
      final bytes = utf8.encode('adhan');
      final catalog = AudioCatalog.fromJson(
        jsonEncode({
          'adhan': [
            {
              'id': 'madinah',
              'nameAr': 'المدينة',
              'nameEn': 'Madinah',
              'main': _file(
                'https://cdn.example/a.mp3',
                bytes,
                phrases: [
                  [0, 5],
                  [6, 9],
                ],
              ),
              'fajr': _file('https://cdn.example/f.mp3', bytes),
            },
            {
              'id': '../evil',
              'nameAr': 'x',
              'nameEn': 'x',
              'main': _file('https://a/b.mp3', bytes),
            },
            {
              'id': 'plain',
              'nameAr': 'x',
              'nameEn': 'x',
              'main': _file('http://insecure/b.mp3', bytes),
            },
            {
              'id': 'nosha',
              'nameAr': 'x',
              'nameEn': 'x',
              'main': {'url': 'https://a/b.mp3', 'bytes': 1, 'durationMs': 1},
            },
            {
              'id': 'local',
              'nameAr': 'x',
              'nameEn': 'x',
              'main': _file('https://a/b.mp3', bytes),
            },
          ],
        }),
      );
      expect(catalog.adhanVoices.map((voice) => voice.id), [
        'local',
        'madinah',
      ]);
      final voice = catalog.voice('madinah');
      expect(voice.fileFor(isFajr: false)!.phrases!.length, 2);
      expect(voice.fileFor(isFajr: true), same(voice.fajr));
      expect(catalog.voice('deleted').isBundled, isTrue);
    });

    test('a voice without a Fajr file uses its main recording for Fajr', () {
      final catalog = AudioCatalog.fromJson(
        jsonEncode({
          'adhan': [
            {
              'id': 'v',
              'nameAr': 'a',
              'nameEn': 'b',
              'main': _file('https://a/b.mp3', [1, 2]),
            },
          ],
        }),
      );
      final voice = catalog.voice('v');
      expect(voice.fileFor(isFajr: true), same(voice.main));
    });

    test('rejects timings that overlap or run backwards', () {
      final file = AdhanFile.fromJson(
        _file(
          'https://a/b.mp3',
          [1],
          phrases: [
            [0, 5],
            [2, 9],
          ],
        ),
      );
      expect(file!.phrases, isNull);
    });

    test('Remote Config can replace the reciter list', () {
      final catalog = AudioCatalog.fromJson(
        jsonEncode({
          'reciters': [
            {
              'id': 'ar.husary',
              'nameAr': 'الحصري',
              'nameEn': 'Husary',
              'bitrate': 128,
            },
            {'id': 'bad id', 'nameAr': 'x', 'nameEn': 'x', 'bitrate': 128},
          ],
        }),
      );
      expect(catalog.reciters.map((reciter) => reciter.id), ['ar.husary']);
      expect(catalog.reciter('missing').id, 'ar.husary');
      expect(
        catalog.reciter('ar.husary').verseUri(7).toString(),
        'https://cdn.islamic.network/quran/audio/128/ar.husary/7.mp3',
      );
    });
  });

  test('settings saved before voices existed keep the bundled adhan', () {
    final settings = AppSettings.fromMap({
      'selectedAdhan': 0,
      'adhanVolume': 0.5,
    });
    expect(settings.adhanVoiceId, 'local');
    final restored = AppSettings.fromMap(
      settings.copyWith(adhanVoiceId: 'madinah').toMap(),
    );
    expect(restored.adhanVoiceId, 'madinah');
    expect(restored == settings, isFalse);
  });

  group('downloads', () {
    test('a verified file is moved into place', () async {
      final bytes = List.generate(5000, (i) => i % 251);
      served['/a.mp3'] = bytes;
      final target = File('${temp.path}/out/a.mp3');
      final progress = <int>[];
      await downloadVerified(
        url: url('/a.mp3'),
        destination: target,
        bytes: bytes.length,
        sha256Hex: _sha(bytes),
        requireHttps: false,
        onProgress: (received, total) => progress.add(received),
      );
      expect(await target.readAsBytes(), bytes);
      expect(progress.last, bytes.length);
      expect(target.parent.listSync().length, 1);
    });

    test('a checksum mismatch leaves no file', () async {
      final bytes = List.filled(100, 7);
      served['/a.mp3'] = bytes;
      final target = File('${temp.path}/out/a.mp3');
      await expectLater(
        downloadVerified(
          url: url('/a.mp3'),
          destination: target,
          bytes: bytes.length,
          sha256Hex: _sha([1, 2, 3]),
          requireHttps: false,
        ),
        throwsA(isA<PackIntegrityException>()),
      );
      expect(target.existsSync(), isFalse);
      expect(target.parent.listSync(), isEmpty);
    });

    test('a wrong size and a 404 leave no file', () async {
      served['/a.mp3'] = List.filled(100, 7);
      final target = File('${temp.path}/out/a.mp3');
      await expectLater(
        downloadVerified(
          url: url('/a.mp3'),
          destination: target,
          bytes: 99,
          sha256Hex: _sha(List.filled(100, 7)),
          requireHttps: false,
        ),
        throwsA(isA<PackIntegrityException>()),
      );
      await expectLater(
        downloadVerified(
          url: url('/missing.mp3'),
          destination: target,
          bytes: 1,
          sha256Hex: _sha([1]),
          requireHttps: false,
        ),
        throwsA(isA<HttpException>()),
      );
      expect(target.parent.listSync(), isEmpty);
    });

    test('plain HTTP is refused by default', () async {
      await expectLater(
        downloadVerified(
          url: url('/a.mp3'),
          destination: File('${temp.path}/a.mp3'),
          bytes: 1,
          sha256Hex: _sha([1]),
        ),
        throwsA(isA<PackIntegrityException>()),
      );
    });

    test('cancelling removes the partial download', () async {
      final bytes = List.filled(200000, 3);
      served['/a.mp3'] = bytes;
      final cancel = CancelToken();
      final target = File('${temp.path}/out/a.mp3');
      await expectLater(
        downloadVerified(
          url: url('/a.mp3'),
          destination: target,
          bytes: bytes.length,
          sha256Hex: _sha(bytes),
          requireHttps: false,
          cancel: cancel,
          onProgress: (_, _) => cancel.cancel(),
        ),
        throwsA(isA<PackCancelled>()),
      );
      expect(target.parent.listSync(), isEmpty);
    });
  });

  group('library', () {
    late AudioLibrary library;
    late AdhanVoice voice;
    final main = utf8.encode('main adhan recording');
    final fajr = utf8.encode('fajr adhan recording!');
    final clip = utf8.encode('ios clip');

    setUp(() {
      library = AudioLibrary(
        support: Directory('${temp.path}/support'),
        soundsDirectory: Directory('${temp.path}/Library/Sounds'),
      );
      served['/main.mp3'] = main;
      served['/fajr.mp3'] = fajr;
      served['/clip.caf'] = clip;
      // The catalog only accepts HTTPS, so build the voice directly for the
      // local test server.
      voice = AdhanVoice(
        id: 'madinah',
        nameAr: 'المدينة',
        nameEn: 'Madinah',
        main: AdhanFile(
          url: url('/main.mp3'),
          sha256: _sha(main),
          bytes: main.length,
          durationMs: 5000,
          iosUrl: url('/clip.caf'),
          iosSha256: _sha(clip),
          iosBytes: clip.length,
        ),
        fajr: AdhanFile(
          url: url('/fajr.mp3'),
          sha256: _sha(fajr),
          bytes: fajr.length,
          durationMs: 5000,
        ),
      );
    });

    test('downloads, reports progress, and exposes files per prayer', () async {
      expect(await library.isAdhanInstalled(voice), isFalse);
      expect(await library.installedAdhan(voice, isFajr: false), isNull);
      final progress = <double>[];
      await library.downloadAdhan(
        voice,
        onProgress: progress.add,
        requireHttps: false,
      );
      expect(progress.last, closeTo(1, 1e-9));
      expect(await library.isAdhanInstalled(voice), isTrue);
      expect(
        await (await library.installedAdhan(
          voice,
          isFajr: false,
        ))!.readAsBytes(),
        main,
      );
      expect(
        await (await library.installedAdhan(
          voice,
          isFajr: true,
        ))!.readAsBytes(),
        fajr,
      );
      final sound = await library.iosSoundName(voice, isFajr: false);
      expect(sound, startsWith('madinah-'));
      expect(
        File('${temp.path}/Library/Sounds/$sound').readAsBytesSync(),
        clip,
      );
      // Fajr has no clip of its own in this catalog entry.
      expect(await library.iosSoundName(voice, isFajr: true), isNull);
    });

    test(
      'a missing or truncated file falls back to the bundled adhan',
      () async {
        await library.downloadAdhan(voice, requireHttps: false);
        final saved = (await library.installedAdhan(voice, isFajr: false))!;
        await saved.writeAsBytes([1, 2]);
        expect(await library.installedAdhan(voice, isFajr: false), isNull);
        expect(await library.isAdhanInstalled(voice), isFalse);
      },
    );

    test('a failed download installs nothing', () async {
      served['/main.mp3'] = List.of(main)..[0] ^= 1;
      await expectLater(
        library.downloadAdhan(voice, requireHttps: false),
        throwsA(isA<PackIntegrityException>()),
      );
      expect(await library.installedAdhan(voice, isFajr: false), isNull);
      expect(Directory('${temp.path}/Library/Sounds').existsSync(), isFalse);
    });

    test('deleting removes the voice and its iOS sounds only', () async {
      await library.downloadAdhan(voice, requireHttps: false);
      Directory('${temp.path}/Library/Sounds').createSync(recursive: true);
      File('${temp.path}/Library/Sounds/other-1.caf').writeAsBytesSync([1]);
      await library.deleteAdhan(voice);
      expect(await library.isAdhanInstalled(voice), isFalse);
      expect(await library.iosSoundName(voice, isFajr: false), isNull);
      expect(
        File('${temp.path}/Library/Sounds/other-1.caf').existsSync(),
        isTrue,
      );
    });

    test('Alafasy keeps the folder earlier versions used', () {
      final alafasy = builtInReciters.first;
      final husary = builtInReciters[1];
      expect(
        library.recitationDir(alafasy).path,
        endsWith('support/recitation_alafasy'),
      );
      expect(
        library.recitationDir(husary).path,
        endsWith('support/audio_packs/recitation/ar.husary'),
      );
    });
  });

  group('mushaf pack', () {
    // A chunk in the "TMNP" format written by tool/make_mushaf_pack.py.
    List<int> pack(Map<int, List<int>> pages) {
      final header = BytesBuilder()
        ..add(utf8.encode('TMNP'))
        ..add((ByteData(4)..setUint32(0, pages.length)).buffer.asUint8List());
      for (final entry in pages.entries) {
        final item = ByteData(6)
          ..setUint16(0, entry.key)
          ..setUint32(2, entry.value.length);
        header.add(item.buffer.asUint8List());
      }
      for (final bytes in pages.values) {
        header.add(bytes);
      }
      return header.toBytes();
    }

    test(
      'downloads chunks, installs their pages, and skips them next time',
      () async {
        final first = pack({
          6: [1, 1, 1],
          7: [2, 2],
        });
        final second = pack({
          8: [3],
        });
        served['/a.pack'] = first;
        served['/b.pack'] = second;
        final catalog = MushafPack(
          bundledPages: 5,
          chunks: [
            MushafChunk(
              from: 6,
              to: 7,
              url: url('/a.pack'),
              sha256: _sha(first),
              bytes: first.length,
            ),
            MushafChunk(
              from: 8,
              to: 8,
              url: url('/b.pack'),
              sha256: _sha(second),
              bytes: second.length,
            ),
          ],
        );
        final pages = MushafPages.instance..reset();
        AudioLibrary.debugInstance = AudioLibrary(
          support: Directory('${temp.path}/support'),
        );
        addTearDown(() {
          AudioLibrary.debugInstance = null;
          pages.reset();
        });
        await pages.init();
        expect(pages.has(3), isTrue); // bundled
        expect(pages.has(6), isFalse);
        expect(pages.provider(6), isNull);
        expect(pages.remainingBytes(catalog), first.length + second.length);

        final progress = <double>[];
        await pages.download(
          catalog,
          onProgress: progress.add,
          requireHttps: false,
        );
        expect(progress.last, closeTo(1, 1e-9));
        expect([6, 7, 8].every(pages.has), isTrue);
        expect(pages.provider(7), isA<FileImage>());
        expect(File('${temp.path}/support/mushaf/006.webp').readAsBytesSync(), [
          1,
          1,
          1,
        ]);
        expect(pages.remainingBytes(catalog), 0);
        expect(
          Directory('${temp.path}/support/mushaf/.downloads').listSync(),
          isEmpty,
        );

        // A fresh start finds the pages that were saved.
        pages.reset();
        await pages.init();
        expect(pages.has(8), isTrue);
        await pages.remove();
        expect(pages.has(8), isFalse);
      },
    );

    test('a pack whose pages fall outside its range is rejected', () async {
      final bad = pack({
        99: [1],
      });
      served['/bad.pack'] = bad;
      final catalog = MushafPack(
        bundledPages: 5,
        chunks: [
          MushafChunk(
            from: 6,
            to: 7,
            url: url('/bad.pack'),
            sha256: _sha(bad),
            bytes: bad.length,
          ),
        ],
      );
      final pages = MushafPages.instance..reset();
      AudioLibrary.debugInstance = AudioLibrary(
        support: Directory('${temp.path}/support'),
      );
      addTearDown(() {
        AudioLibrary.debugInstance = null;
        pages.reset();
      });
      await expectLater(
        pages.download(catalog, requireHttps: false),
        throwsA(isA<PackIntegrityException>()),
      );
      expect(pages.has(99), isFalse);
    });

    test(
      'the catalog parser accepts the bundled manifest and rejects bad chunks',
      () {
        final good =
            jsonDecode(File('assets/data/packs.json').readAsStringSync())
                as Map;
        final catalog = AudioCatalog.fromJson(jsonEncode(good));
        expect(catalog.mushaf, isNotNull);
        expect(catalog.mushaf!.chunks.first.from, 6);
        expect(catalog.mushaf!.chunks.last.to, 604);
        expect(catalog.adhanVoices.map((voice) => voice.id), [
          'local',
          'doha',
          'asim',
          'klcc',
          'mirza',
          'nisad',
          'madinah',
          'azan',
        ]);
        final doha = catalog.voice('doha');
        expect(doha.fajr, isNotNull);
        expect(doha.fileFor(isFajr: true), same(doha.fajr));
        expect(doha.fileFor(isFajr: false)!.phrases, isNull);
        expect(doha.credit, contains('Public Domain'));
        expect(
          MushafPack.fromJson({
            'bundledPages': 5,
            'chunks': [
              {
                'from': 3,
                'to': 9,
                'url': 'https://a/b',
                'sha256': 'x' * 64,
                'bytes': 1,
              },
            ],
          }),
          isNull,
        );
        // Remote Config overlays the bundled catalog instead of replacing it.
        final merged = AudioCatalog.fromJson('{"adhan": []}', base: catalog);
        expect(merged.mushaf, isNotNull);
        expect(merged.adhanVoices.length, catalog.adhanVoices.length);
      },
    );
  });

  group('published catalog', () {
    test(
      'a new voice in the published file shows up without an app update',
      () async {
        served['/packs.json'] = utf8.encode(
          jsonEncode({
            'adhan': [
              {
                'id': 'fresh',
                'nameAr': 'جديد',
                'nameEn': 'Fresh',
                'main': _file('https://cdn.example/fresh.mp3', [1, 2, 3]),
                'credit': 'Someone, CC0',
              },
            ],
          }),
        );
        final body = await fetchCatalogJson(url('/packs.json'));
        expect(body, isNotNull);
        final base = AudioCatalog.fromJson(
          File('assets/data/packs.json').readAsStringSync(),
        );
        final updated = AudioCatalog.fromJson(body!, base: base);
        expect(updated.adhanVoices.map((v) => v.id), contains('fresh'));
        expect(updated.adhanVoices.length, base.adhanVoices.length + 1);
        expect(updated.mushaf, isNotNull);
        expect(updated.voice('fresh').credit, 'Someone, CC0');
      },
    );

    test('an unreachable or oversized catalog is ignored', () async {
      expect(await fetchCatalogJson(url('/missing.json')), isNull);
      served['/big.json'] = List.filled(300 * 1024, 32);
      expect(await fetchCatalogJson(url('/big.json')), isNull);
    });
  });
}
