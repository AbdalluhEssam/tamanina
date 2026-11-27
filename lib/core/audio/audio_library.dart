import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../config/remote_settings.dart';
import 'audio_catalog.dart';
import 'pack_downloader.dart';

DateTime? _catalogLoadedAt;
AudioCatalog? _catalog;

/// Replaces the Remote Config catalog in tests.
@visibleForTesting
AudioCatalog? debugCatalog;

/// Where new adhan voices, reciters and Mushaf packs are published. Updating
/// this file (in the packs repository) changes what every installed app offers,
/// without an app release.
const publishedCatalogUrl =
    'https://raw.githubusercontent.com/AbdalluhEssam/tamanina-packs/main/packs.json';

const _catalogCacheKey = 'audio_catalog_cache';
const _maxCatalogBytes = 256 * 1024;

Future<AudioCatalog> _bundledCatalog() async {
  try {
    return AudioCatalog.fromJson(
      await rootBundle.loadString('assets/data/packs.json'),
    );
  } catch (_) {
    return AudioCatalog.fallback;
  }
}

/// Downloads the published catalog JSON, or null when it is unreachable.
Future<String?> fetchCatalogJson(
  Uri url, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final request = await client.getUrl(url).timeout(timeout);
    request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
    final response = await request.close().timeout(timeout);
    if (response.statusCode != HttpStatus.ok ||
        response.contentLength > _maxCatalogBytes) {
      await response.drain<void>();
      return null;
    }
    final bytes = <int>[];
    await for (final chunk in response.timeout(timeout)) {
      bytes.addAll(chunk);
      if (bytes.length > _maxCatalogBytes) return null;
    }
    return utf8.decode(bytes);
  } catch (_) {
    return null;
  } finally {
    client.close(force: true);
  }
}

/// The catalog the app offers: the bundled one, updated by the published
/// catalog file (last good copy is kept for offline use), then by Remote Config.
/// [force] skips the 10-minute memory cache. With [network] false nothing is
/// fetched: the memory copy, or the bundled catalog plus the last saved copy, is
/// used, so playback code never waits on the connection.
Future<AudioCatalog> loadAudioCatalog({
  bool force = false,
  bool network = true,
}) async {
  if (debugCatalog case final catalog?) return catalog;
  final loadedAt = _catalogLoadedAt;
  final cached = _catalog;
  if (!network && cached != null) return cached;
  if (!force &&
      cached != null &&
      loadedAt != null &&
      DateTime.now().difference(loadedAt) < const Duration(minutes: 10)) {
    return cached;
  }
  try {
    var catalog = await _bundledCatalog();
    final preferences = await SharedPreferences.getInstance();
    final published = network
        ? await fetchCatalogJson(Uri.parse(publishedCatalogUrl))
        : null;
    if (published != null) {
      await preferences.setString(_catalogCacheKey, published);
    }
    final json = published ?? preferences.getString(_catalogCacheKey);
    if (json != null) catalog = AudioCatalog.fromJson(json, base: catalog);
    try {
      final config = network
          ? await remoteConfig()
          : FirebaseRemoteConfig.instance;
      catalog = AudioCatalog.fromJson(
        config.getString('audio_catalog'),
        base: catalog,
      );
    } catch (_) {
      // Remote Config is optional.
    }
    // A catalog built without the network is not remembered as fresh.
    if (!network) return catalog;
    return _catalog = catalog;
  } catch (_) {
    return cached ?? await _bundledCatalog();
  } finally {
    _catalogLoadedAt = DateTime.now();
  }
}

/// Downloaded audio on this device: adhan voices and Quran reciters.
///
/// Everything lives under one folder in Application Support that is excluded
/// from backups. The bundled adhan stays in the app, so a fresh install always
/// has a working adhan.
class AudioLibrary {
  AudioLibrary({required this.support, this.soundsDirectory});

  static Future<AudioLibrary>? _opening;

  /// Replaces the on-device library in tests.
  @visibleForTesting
  static AudioLibrary? debugInstance;

  static Future<AudioLibrary> open() async =>
      debugInstance ?? await (_opening ??= _open());

  static Future<AudioLibrary> _open() async {
    final support = await getApplicationSupportDirectory();
    Directory? sounds;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      sounds = Directory('${(await getLibraryDirectory()).path}/Sounds');
    }
    return AudioLibrary(support: support, soundsDirectory: sounds);
  }

  final Directory support;

  /// iOS notification sounds must live in `Library/Sounds`.
  final Directory? soundsDirectory;

  Directory get root => Directory('${support.path}/audio_packs');

  // ── Adhan ────────────────────────────────────────────────────────────────

  Directory _voiceDir(AdhanVoice voice) =>
      Directory('${root.path}/adhan/${voice.id}');

  String _tag(String sha) => sha.substring(0, 12);

  File _adhanFile(AdhanVoice voice, AdhanFile file) =>
      File('${_voiceDir(voice).path}/${_tag(file.sha256)}.mp3');

  File _clipFile(AdhanVoice voice, AdhanFile file) =>
      File('${_voiceDir(voice).path}/${_tag(file.iosSha256!)}.caf');

  String _soundName(AdhanVoice voice, AdhanFile file) =>
      '${voice.id}-${_tag(file.iosSha256!)}.caf';

  Future<bool> _valid(File file, int bytes) async =>
      await file.exists() && await file.length() == bytes;

  /// The downloaded recording to play, or null to use the bundled adhan.
  Future<File?> installedAdhan(AdhanVoice voice, {required bool isFajr}) async {
    final file = voice.fileFor(isFajr: isFajr);
    if (file == null) return null;
    final saved = _adhanFile(voice, file);
    return await _valid(saved, file.bytes) ? saved : null;
  }

  /// The iOS notification sound name for [voice], once its clip is installed.
  Future<String?> iosSoundName(AdhanVoice voice, {required bool isFajr}) async {
    final directory = soundsDirectory;
    final file = voice.fileFor(isFajr: isFajr);
    if (directory == null || file == null || file.iosSha256 == null) {
      return null;
    }
    final name = _soundName(voice, file);
    return await _valid(File('${directory.path}/$name'), file.iosBytes!)
        ? name
        : null;
  }

  Future<bool> isAdhanInstalled(AdhanVoice voice) async {
    if (voice.isBundled) return true;
    for (final file in voice.files) {
      if (!await _valid(_adhanFile(voice, file), file.bytes)) return false;
      if (soundsDirectory != null && file.iosSha256 != null) {
        final clip = File(
          '${soundsDirectory!.path}/${_soundName(voice, file)}',
        );
        if (!await _valid(clip, file.iosBytes!)) return false;
      }
    }
    return true;
  }

  /// Bytes to download for [voice] on this platform.
  int downloadBytes(AdhanVoice voice) => voice.files.fold(
    0,
    (sum, file) =>
        sum +
        file.bytes +
        (soundsDirectory != null && file.iosSha256 != null
            ? file.iosBytes!
            : 0),
  );

  /// Downloads and verifies every file of [voice]. [onProgress] reports 0..1.
  Future<void> downloadAdhan(
    AdhanVoice voice, {
    void Function(double progress)? onProgress,
    CancelToken? cancel,
    bool requireHttps = true,
  }) async {
    final total = downloadBytes(voice);
    var done = 0;
    Future<void> fetch(
      Uri url,
      File target,
      int bytes,
      String sha, {
      File? copyTo,
    }) async {
      if (!await _valid(target, bytes)) {
        await downloadVerified(
          url: url,
          destination: target,
          bytes: bytes,
          sha256Hex: sha,
          requireHttps: requireHttps,
          cancel: cancel,
          onProgress: (received, _) =>
              onProgress?.call((done + received) / total),
        );
      }
      if (copyTo != null && !await _valid(copyTo, bytes)) {
        await copyTo.parent.create(recursive: true);
        await target.copy(copyTo.path);
      }
      done += bytes;
      onProgress?.call(done / total);
    }

    for (final file in voice.files) {
      await fetch(file.url, _adhanFile(voice, file), file.bytes, file.sha256);
      if (soundsDirectory != null && file.iosSha256 != null) {
        await fetch(
          file.iosUrl!,
          _clipFile(voice, file),
          file.iosBytes!,
          file.iosSha256!,
          copyTo: File('${soundsDirectory!.path}/${_soundName(voice, file)}'),
        );
      }
    }
  }

  Future<void> deleteAdhan(AdhanVoice voice) async {
    final directory = _voiceDir(voice);
    if (await directory.exists()) await directory.delete(recursive: true);
    final sounds = soundsDirectory;
    if (sounds != null && await sounds.exists()) {
      await for (final entry in sounds.list()) {
        if (entry is File &&
            entry.uri.pathSegments.last.startsWith('${voice.id}-')) {
          await entry.delete();
        }
      }
    }
  }

  // ── Reciters ─────────────────────────────────────────────────────────────

  /// Alafasy keeps the folder earlier versions used, so saved pages stay.
  Directory recitationDir(Reciter reciter) => reciter.id == defaultReciterId
      ? Directory('${support.path}/recitation_alafasy')
      : Directory('${root.path}/recitation/${reciter.id}');

  Future<int> directorySize(Directory directory) async {
    if (!await directory.exists()) return 0;
    var total = 0;
    await for (final entry in directory.list(recursive: true)) {
      if (entry is File) total += await entry.length();
    }
    return total;
  }

  Future<void> deleteRecitation(Reciter reciter) async {
    final directory = recitationDir(reciter);
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}

const _reciterKey = 'recitation_reciter';

Future<String> savedReciterId() async =>
    (await SharedPreferences.getInstance()).getString(_reciterKey) ??
    defaultReciterId;

Future<void> saveReciterId(String id) async =>
    (await SharedPreferences.getInstance()).setString(_reciterKey, id);

/// The reciter the user chose, or Alafasy if that reciter is no longer listed.
Future<Reciter> selectedReciter() async =>
    (await loadAudioCatalog()).reciter(await savedReciterId());
