import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:quran_sharif/quran_sharif.dart';

class RecitationStore {
  RecitationStore(this._directory);

  final Directory _directory;

  static Future<RecitationStore> open() async {
    final support = await getApplicationSupportDirectory();
    return RecitationStore(Directory('${support.path}/recitation_alafasy'));
  }

  File fileFor(Ayahs verse) => File('${_directory.path}/${verse.number}.mp3');

  Future<File?> savedFileFor(Ayahs verse) async {
    final file = fileFor(verse);
    return await file.exists() && await file.length() > 0 ? file : null;
  }

  Future<void> downloadPage(Iterable<Ayahs> verses, HttpClient client) async {
    await _directory.create(recursive: true);
    for (final verse in verses) {
      final file = fileFor(verse);
      if (await savedFileFor(verse) != null) continue;
      final uri = Uri.parse(verse.audio);
      if (uri.scheme != 'https' || uri.host != 'cdn.islamic.network') {
        throw StateError('Recitation source is unavailable');
      }
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 10));
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode != HttpStatus.ok) {
        await response.timeout(const Duration(seconds: 10)).drain<void>();
        throw HttpException('Recitation download failed', uri: uri);
      }
      final temporary = await _directory.createTemp('download_');
      final draft = File('${temporary.path}/audio.part');
      try {
        final sink = draft.openWrite();
        try {
          await sink.addStream(response.timeout(const Duration(seconds: 15)));
        } finally {
          await sink.close();
        }
        final length = await draft.length();
        if (length == 0 ||
            (response.contentLength >= 0 && length != response.contentLength)) {
          throw const FormatException('Incomplete recitation audio');
        }
        await draft.rename(file.path);
      } finally {
        await temporary.delete(recursive: true);
      }
    }
  }
}
