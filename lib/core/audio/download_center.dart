import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/chatbot/data/services/local_assistant_model.dart';
import '../../features/quran/data/services/mushaf_pages.dart';
import 'audio_catalog.dart';
import 'audio_library.dart';
import 'pack_downloader.dart';

/// Runs pack downloads (Mushaf pages, adhan voices, the on-device assistant)
/// one after another and reports progress. Downloads continue while the app is
/// open, even after the sheet that started them is closed.
class DownloadCenter extends ChangeNotifier {
  DownloadCenter._();

  static final instance = DownloadCenter._();

  static const mushafId = 'mushaf';
  static const assistantId = 'assistant';
  static String adhanId(String voice) => 'adhan:$voice';

  final _progress = <String, double>{};
  final _failed = <String>{};
  final _tokens = <String, CancelToken>{};
  Future<void> _queue = Future.value();

  bool isRunning(String id) => _progress.containsKey(id);
  double? progress(String id) => _progress[id];
  bool hasFailed(String id) => _failed.contains(id);
  bool get busy => _progress.isNotEmpty;

  /// Queues [ids] and returns when all of them finished or failed.
  Future<void> start(Iterable<String> ids, AudioCatalog catalog) {
    final wanted = ids.where((id) => !isRunning(id)).toList();
    for (final id in wanted) {
      _failed.remove(id);
      _progress[id] = 0;
      _tokens[id] = CancelToken();
    }
    notifyListeners();
    return _queue = _queue.then((_) async {
      for (final id in wanted) {
        await _run(id, catalog);
      }
    });
  }

  void cancel(String id) {
    _tokens[id]?.cancel();
    if (id == assistantId) LocalAssistantModel.instance.cancelDownload();
  }

  Future<void> _run(String id, AudioCatalog catalog) async {
    final token = _tokens[id]!;
    if (token.isCancelled) return _finish(id);
    void report(double value) {
      _progress[id] = value;
      notifyListeners();
    }

    try {
      if (id == mushafId) {
        final pack = catalog.mushaf;
        if (pack == null) throw StateError('No Mushaf pack in the catalog');
        await MushafPages.instance.download(
          pack,
          onProgress: report,
          cancel: token,
        );
      } else if (id == assistantId) {
        await _downloadAssistant(report);
      } else if (id.startsWith('adhan:')) {
        final voice = catalog.voice(id.substring(6));
        if (voice.isBundled) return _finish(id);
        await (await AudioLibrary.open()).downloadAdhan(
          voice,
          onProgress: report,
          cancel: token,
        );
      }
    } on PackCancelled {
      // Stopped by the user.
    } catch (_) {
      _failed.add(id);
    }
    _finish(id);
  }

  Future<void> _downloadAssistant(void Function(double) report) async {
    final model = LocalAssistantModel.instance;
    void listener() => report(model.percent / 100);
    model.addListener(listener);
    try {
      await model.download();
      if (model.status == LocalModelStatus.failed) {
        throw StateError('Assistant download failed');
      }
    } finally {
      model.removeListener(listener);
    }
  }

  void _finish(String id) {
    _progress.remove(id);
    _tokens.remove(id);
    notifyListeners();
  }

  // ── First-run offer ──────────────────────────────────────────────────────

  static const _offerKey = 'packs_offer_seen';

  static Future<bool> shouldOffer() async =>
      !((await SharedPreferences.getInstance()).getBool(_offerKey) ?? false);

  static Future<void> markOffered() async =>
      (await SharedPreferences.getInstance()).setBool(_offerKey, true);
}
