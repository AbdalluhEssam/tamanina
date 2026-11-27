import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';

class PackIntegrityException implements Exception {
  const PackIntegrityException(this.reason);
  final String reason;
  @override
  String toString() => 'PackIntegrityException: $reason';
}

class PackCancelled implements Exception {
  const PackCancelled();
}

class CancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

/// Downloads one file over HTTPS, checks its size and SHA-256, and only then
/// moves it into place. A failed or cancelled download leaves nothing behind.
Future<File> downloadVerified({
  required Uri url,
  required File destination,
  required int bytes,
  required String sha256Hex,
  void Function(int received, int total)? onProgress,
  CancelToken? cancel,
  bool requireHttps = true,
  Duration timeout = const Duration(seconds: 20),
}) async {
  if (requireHttps && url.scheme != 'https') {
    throw const PackIntegrityException('Downloads must use HTTPS');
  }
  await destination.parent.create(recursive: true);
  final draft = File(
    '${destination.path}.${DateTime.now().microsecondsSinceEpoch}.part',
  );
  final client = HttpClient()
    ..connectionTimeout = timeout
    ..autoUncompress = false;
  try {
    final request = await client.getUrl(url).timeout(timeout);
    // The checksums are of the raw files, so never accept a compressed stream.
    request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
    final response = await request.close().timeout(timeout);
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      throw HttpException('Download failed (${response.statusCode})', uri: url);
    }
    if (response.contentLength >= 0 && response.contentLength != bytes) {
      await response.drain<void>();
      throw const PackIntegrityException('Unexpected file size');
    }
    final digest = AccumulatorSink<Digest>();
    final hash = sha256.startChunkedConversion(digest);
    final sink = draft.openWrite();
    var received = 0;
    try {
      await for (final chunk in response.timeout(timeout)) {
        if (cancel?.isCancelled == true) throw const PackCancelled();
        received += chunk.length;
        if (received > bytes) {
          throw const PackIntegrityException('File is larger than expected');
        }
        hash.add(chunk);
        sink.add(chunk);
        onProgress?.call(received, bytes);
      }
    } finally {
      await sink.close();
    }
    hash.close();
    if (cancel?.isCancelled == true) throw const PackCancelled();
    if (received != bytes ||
        digest.events.single.toString() != sha256Hex.toLowerCase()) {
      throw const PackIntegrityException('Checksum mismatch');
    }
    if (await destination.exists()) await destination.delete();
    return await draft.rename(destination.path);
  } finally {
    client.close(force: true);
    if (await draft.exists()) await draft.delete();
  }
}

/// Collects the single digest produced by a chunked hash conversion.
class AccumulatorSink<T> implements Sink<T> {
  final events = <T>[];
  @override
  void add(T data) => events.add(data);
  @override
  void close() {}
}
