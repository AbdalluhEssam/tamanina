import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_catalog.dart';
import '../../../../core/audio/audio_library.dart';
import '../../../../core/audio/download_center.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../../../chatbot/data/services/local_assistant_model.dart';
import '../../../quran/data/services/mushaf_pages.dart';

/// Lets the user choose and download the optional packs. Shown once after the
/// first launch and available later from Settings.
Future<void> showPacksSheet(BuildContext context, {bool firstRun = false}) {
  if (firstRun) unawaited(DownloadCenter.markOffered());
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PacksSheet(firstRun: firstRun),
  );
}

class _PackRow {
  const _PackRow({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.detailAr,
    required this.detailEn,
    required this.bytes,
    required this.installed,
    required this.recommended,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String detailAr;
  final String detailEn;
  final int bytes;
  final bool installed;
  final bool recommended;
}

class _PacksSheet extends StatefulWidget {
  const _PacksSheet({required this.firstRun});

  final bool firstRun;

  @override
  State<_PacksSheet> createState() => _PacksSheetState();
}

class _PacksSheetState extends State<_PacksSheet> {
  late Future<List<_PackRow>> _rows = _load();
  var _wasBusy = false;
  final _selected = <String>{};
  var _initialized = false;
  late AudioCatalog _catalog;

  Future<List<_PackRow>> _load() async {
    _catalog = await loadAudioCatalog();
    final library = await AudioLibrary.open();
    await MushafPages.instance.init();
    await LocalAssistantModel.instance.check();
    final rows = <_PackRow>[];
    final mushaf = _catalog.mushaf;
    if (mushaf != null) {
      rows.add(
        _PackRow(
          id: DownloadCenter.mushafId,
          titleAr: 'صفحات المصحف',
          titleEn: 'Mushaf pages',
          detailAr: 'القراءة بالصفحات المطبوعة بدون إنترنت',
          detailEn: 'Read the printed pages offline',
          bytes: MushafPages.instance.remainingBytes(mushaf),
          installed: MushafPages.instance.remainingBytes(mushaf) == 0,
          recommended: true,
        ),
      );
    }
    for (final voice in _catalog.adhanVoices.where((v) => !v.isBundled)) {
      rows.add(
        _PackRow(
          id: DownloadCenter.adhanId(voice.id),
          titleAr: 'أذان: ${voice.nameAr}',
          titleEn: 'Adhan: ${voice.nameEn}',
          detailAr: voice.credit ?? 'صوت مؤذن إضافي',
          detailEn: voice.credit ?? 'Additional muezzin voice',
          bytes: library.downloadBytes(voice),
          installed: await library.isAdhanInstalled(voice),
          recommended: false,
        ),
      );
    }
    final model = LocalAssistantModel.instance;
    if (model.supported) {
      rows.add(
        _PackRow(
          id: DownloadCenter.assistantId,
          titleAr: 'المساعد على الجهاز',
          titleEn: 'On-device assistant',
          detailAr:
              'اختياري. المساعد يعمل أونلاين في الأثناء، وهذا يتيح الإجابة بدون إنترنت.',
          detailEn:
              'Optional. The assistant works online meanwhile; this lets it answer offline.',
          bytes: LocalAssistantModel.expectedBytes,
          installed: model.status == LocalModelStatus.ready,
          recommended: false,
        ),
      );
    }
    return rows;
  }

  @override
  void initState() {
    super.initState();
    DownloadCenter.instance.addListener(_onDownloads);
  }

  @override
  void dispose() {
    DownloadCenter.instance.removeListener(_onDownloads);
    super.dispose();
  }

  /// Re-reads what is installed once a batch of downloads finishes.
  void _onDownloads() {
    final busy = DownloadCenter.instance.busy;
    if (_wasBusy && !busy && mounted) {
      setState(() {
        _selected.clear();
        _rows = _load();
      });
    }
    _wasBusy = busy;
  }

  String _size(int bytes) => bytes >= 1 << 20
      ? '${(bytes / (1 << 20)).toStringAsFixed(bytes >= 100 << 20 ? 0 : 1)} MB'
      : '${(bytes / 1024).ceil()} KB';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: FutureBuilder<List<_PackRow>>(
          future: _rows,
          builder: (context, snapshot) {
            final rows = snapshot.data;
            if (rows == null) {
              return const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!_initialized) {
              _initialized = true;
              _selected.addAll(
                rows
                    .where((r) => r.recommended && !r.installed)
                    .map((r) => r.id),
              );
            }
            return ListenableBuilder(
              listenable: DownloadCenter.instance,
              builder: (context, _) => _content(context, rows),
            );
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, List<_PackRow> rows) {
    final center = DownloadCenter.instance;
    final pending = rows.where((r) => _selected.contains(r.id) && !r.installed);
    final total = pending.fold<int>(0, (sum, r) => sum + r.bytes);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Column(
            children: [
              Text(
                appText(
                  context,
                  widget.firstRun ? 'حمّل ما تحتاجه' : 'التحميلات',
                  widget.firstRun ? 'Download what you need' : 'Downloads',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                appText(
                  context,
                  'التطبيق خفيف، وكل شيء إضافي يُحمَّل مرة واحدة ويبقى على جهازك. يُفضَّل استخدام Wi-Fi.',
                  'The app stays small. Extras download once and stay on your device. Wi-Fi is best.',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [for (final row in rows) _row(context, row, center)],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    appText(
                      context,
                      widget.firstRun ? 'لاحقًا' : 'إغلاق',
                      widget.firstRun ? 'Later' : 'Close',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: pending.isEmpty || center.busy
                      ? null
                      : () => unawaited(
                          center.start(pending.map((r) => r.id), _catalog),
                        ),
                  child: Text(
                    pending.isEmpty
                        ? appText(context, 'لا شيء للتحميل', 'Nothing selected')
                        : appText(
                            context,
                            'حمّل (${_size(total)})',
                            'Download (${_size(total)})',
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, _PackRow row, DownloadCenter center) {
    final running = center.isRunning(row.id);
    final progress = center.progress(row.id);
    final failed = center.hasFailed(row.id);
    return CheckboxListTile(
      value: row.installed || _selected.contains(row.id),
      onChanged: row.installed || running
          ? null
          : (value) => setState(() {
              if (value == true) {
                _selected.add(row.id);
              } else {
                _selected.remove(row.id);
              }
            }),
      title: Text(appText(context, row.titleAr, row.titleEn)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${appText(context, row.detailAr, row.detailEn)} • ${_size(row.bytes)}',
          ),
          if (running)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (progress ?? 0) > 0 ? progress : null,
                    ),
                  ),
                  IconButton(
                    tooltip: appText(context, 'إلغاء', 'Cancel'),
                    icon: const Icon(Icons.close),
                    onPressed: () => center.cancel(row.id),
                  ),
                ],
              ),
            ),
          if (failed)
            Text(
              appText(
                context,
                'تعذّر التحميل. تحقق من الاتصال وحاول مرة أخرى.',
                'Download failed. Check your connection and try again.',
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (row.installed) Text(appText(context, 'محمّل', 'Downloaded')),
        ],
      ),
    );
  }
}
