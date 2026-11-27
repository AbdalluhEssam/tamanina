import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../../../../core/audio/audio_catalog.dart';
import '../../../../core/audio/audio_library.dart';
import '../../../../core/audio/pack_downloader.dart';

/// Printed Mushaf pages. The first few pages ship inside the app; the rest are
/// downloaded once (about 36 MB) and kept in Application Support.
class MushafPages extends ChangeNotifier {
  MushafPages._();

  static final instance = MushafPages._();

  /// Pages 1..[bundledPages] are bundled assets (`assets/mushaf/NNN.webp`).
  static const bundledPages = 5;
  static const totalPages = 604;

  Directory? _directory;
  final _have = <int>{};
  Future<void>? _initializing;

  Future<void> init({Directory? directory}) =>
      _initializing ??= _init(directory);

  Future<void> _init(Directory? override) async {
    final library = await AudioLibrary.open();
    final folder = override ?? Directory('${library.support.path}/mushaf');
    _directory = folder;
    if (await folder.exists()) {
      await for (final entry in folder.list()) {
        final name = entry.uri.pathSegments.last;
        final number = int.tryParse(name.replaceAll('.webp', ''));
        if (entry is File &&
            name.endsWith('.webp') &&
            number != null &&
            await entry.length() > 0) {
          _have.add(number);
        }
      }
    }
    notifyListeners();
  }

  /// Resets state so tests can start from a clean slate.
  @visibleForTesting
  void reset() {
    _initializing = null;
    _directory = null;
    _have.clear();
  }

  int get downloadedCount => _have.length;
  bool get complete => _have.length >= totalPages - bundledPages;

  bool has(int page) => page <= bundledPages || _have.contains(page);

  /// The image for [page], or null when it has not been downloaded.
  ImageProvider? provider(int page) {
    if (page >= 1 && page <= bundledPages) {
      return AssetImage(
        'assets/mushaf/${page.toString().padLeft(3, '0')}.webp',
      );
    }
    final directory = _directory;
    if (directory == null || !_have.contains(page)) return null;
    return FileImage(
      File('${directory.path}/${page.toString().padLeft(3, '0')}.webp'),
    );
  }

  bool _hasAll(MushafChunk chunk) {
    for (var page = chunk.from; page <= chunk.to; page++) {
      if (!_have.contains(page)) return false;
    }
    return true;
  }

  /// Bytes still to download for [pack].
  int remainingBytes(MushafPack pack) => pack.chunks
      .where((chunk) => !_hasAll(chunk))
      .fold(0, (sum, chunk) => sum + chunk.bytes);

  /// Downloads every missing chunk. [onProgress] reports 0..1 of the remaining
  /// bytes.
  Future<void> download(
    MushafPack pack, {
    void Function(double progress)? onProgress,
    CancelToken? cancel,
    bool requireHttps = true,
  }) async {
    await init();
    final directory = _directory!;
    final missing = pack.chunks.where((chunk) => !_hasAll(chunk)).toList();
    final total = missing.fold<int>(0, (sum, chunk) => sum + chunk.bytes);
    var done = 0;
    for (final chunk in missing) {
      final target = File(
        '${directory.path}/.downloads/${chunk.sha256.substring(0, 12)}.pack',
      );
      try {
        await downloadVerified(
          url: chunk.url,
          destination: target,
          bytes: chunk.bytes,
          sha256Hex: chunk.sha256,
          requireHttps: requireHttps,
          cancel: cancel,
          onProgress: (received, _) =>
              onProgress?.call((done + received) / total),
        );
        await _install(chunk, target);
      } finally {
        if (await target.exists()) await target.delete();
      }
      done += chunk.bytes;
      onProgress?.call(done / total);
    }
  }

  /// Unpacks a verified chunk ("TMNP" format, see tool/make_mushaf_pack.py).
  Future<void> _install(MushafChunk chunk, File pack) async {
    final data = await pack.readAsBytes();
    final view = ByteData.sublistView(data);
    if (data.length < 8 || String.fromCharCodes(data.sublist(0, 4)) != 'TMNP') {
      throw const PackIntegrityException('Not a Mushaf pack');
    }
    final count = view.getUint32(4);
    var offset = 8 + count * 6;
    if (count == 0 || count > 700 || offset > data.length) {
      throw const PackIntegrityException('Corrupt Mushaf pack');
    }
    final directory = _directory!;
    await directory.create(recursive: true);
    final pages = <int>[];
    for (var i = 0; i < count; i++) {
      final page = view.getUint16(8 + i * 6);
      final length = view.getUint32(10 + i * 6);
      if (page < chunk.from ||
          page > chunk.to ||
          offset + length > data.length) {
        throw const PackIntegrityException('Corrupt Mushaf pack');
      }
      final name = page.toString().padLeft(3, '0');
      final draft = File('${directory.path}/$name.webp.part');
      await draft.writeAsBytes(
        Uint8List.sublistView(data, offset, offset + length),
        flush: true,
      );
      await draft.rename('${directory.path}/$name.webp');
      offset += length;
      pages.add(page);
    }
    _have.addAll(pages);
    notifyListeners();
  }

  Future<void> remove() async {
    await init();
    final directory = _directory!;
    if (await directory.exists()) await directory.delete(recursive: true);
    _have.clear();
    notifyListeners();
  }

  Future<int> bytesOnDisk() async => (await AudioLibrary.open()).directorySize(
    _directory ?? Directory('/nonexistent'),
  );
}
