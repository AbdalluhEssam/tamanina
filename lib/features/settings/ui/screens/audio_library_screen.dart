import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/audio/audio_catalog.dart';
import '../../../../core/audio/audio_library.dart';
import '../../../../core/audio/pack_downloader.dart';
import '../../../../core/services/notification_service_enhanced.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/widgets/tamanina_ui.dart';

enum AudioLibraryKind { adhan, reciter }

/// Pick, download, preview and delete adhan voices or Quran reciters.
class AudioLibraryScreen extends StatefulWidget {
  const AudioLibraryScreen({required this.kind, super.key});

  final AudioLibraryKind kind;

  @override
  State<AudioLibraryScreen> createState() => _AudioLibraryScreenState();
}

class _AudioLibraryScreenState extends State<AudioLibraryScreen> {
  late final Future<(AudioCatalog, AudioLibrary)> _load = _open();

  Future<(AudioCatalog, AudioLibrary)> _open() async =>
      (await loadAudioCatalog(force: true), await AudioLibrary.open());

  final _progress = <String, double>{};
  final _tokens = <String, CancelToken>{};
  AudioPlayer? _player;
  String? _previewing;
  String? _reciterId;
  var _refresh = 0;

  bool get _adhan => widget.kind == AudioLibraryKind.adhan;

  @override
  void initState() {
    super.initState();
    if (!_adhan) unawaited(_loadReciter());
  }

  Future<void> _loadReciter() async {
    final id = await savedReciterId();
    if (mounted) setState(() => _reciterId = id);
  }

  @override
  void dispose() {
    for (final token in _tokens.values) {
      token.cancel();
    }
    unawaited(_player?.dispose());
    super.dispose();
  }

  void _say(String ar, String en) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(appText(context, ar, en))));

  String _size(int bytes) => bytes >= 1 << 20
      ? '${(bytes / (1 << 20)).toStringAsFixed(1)} MB'
      : '${(bytes / 1024).ceil()} KB';

  Future<void> _selectVoice(AdhanVoice voice, AudioLibrary library) async {
    await context.read<SettingsCubit>().updateAdhanVoice(voice.id);
    await sl<NotificationServiceEnhanced>().refresh();
  }

  Future<void> _download(AdhanVoice voice, AudioLibrary library) async {
    final token = _tokens[voice.id] = CancelToken();
    setState(() => _progress[voice.id] = 0);
    try {
      await library.downloadAdhan(
        voice,
        cancel: token,
        onProgress: (value) {
          if (mounted) setState(() => _progress[voice.id] = value);
        },
      );
      if (!mounted) return;
      await _selectVoice(voice, library);
    } on PackCancelled {
      // The user stopped the download.
    } catch (_) {
      if (mounted) {
        _say(
          'تعذّر التحميل. تحقق من الاتصال وحاول مرة أخرى.',
          'Download failed. Check your connection and try again.',
        );
      }
    } finally {
      _tokens.remove(voice.id);
      if (mounted) {
        setState(() {
          _progress.remove(voice.id);
          _refresh++;
        });
      }
    }
  }

  Future<void> _deleteVoice(
    AdhanVoice voice,
    AudioLibrary library,
    bool selected,
  ) async {
    if (selected) await context.read<SettingsCubit>().updateAdhanVoice('local');
    await library.deleteAdhan(voice);
    await sl<NotificationServiceEnhanced>().refresh();
    if (mounted) setState(() => _refresh++);
  }

  Future<void> _preview(AdhanVoice voice, AudioLibrary library) async {
    final player = _player ??= AudioPlayer();
    if (_previewing == voice.id) {
      setState(() => _previewing = null);
      await player.stop();
      return;
    }
    setState(() => _previewing = voice.id);
    try {
      final file = await library.installedAdhan(voice, isFajr: false);
      if (file != null) {
        await player.setFilePath(file.path);
      } else {
        await player.setAsset('assets/audio/adhan/adhan_local.mp3');
      }
      await player.play();
    } catch (_) {
      if (mounted) _say('تعذّر تشغيل المعاينة.', 'The preview could not play.');
    } finally {
      if (mounted && _previewing == voice.id) {
        setState(() => _previewing = null);
      }
    }
  }

  Future<void> _selectReciter(Reciter reciter) async {
    await saveReciterId(reciter.id);
    if (mounted) setState(() => _reciterId = reciter.id);
  }

  @override
  Widget build(BuildContext context) {
    final title = _adhan
        ? appText(context, 'أصوات الأذان', 'Adhan voices')
        : appText(context, 'القرّاء', 'Reciters');
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder(
        future: _load,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: snapshot.hasError
                  ? Text(appText(context, 'تعذّر التحميل', 'Could not load'))
                  : const CircularProgressIndicator(),
            );
          }
          final (catalog, library) = data;
          return SafeArea(
            child: _adhan
                ? _voices(context, catalog, library)
                : _reciters(context, catalog, library),
          );
        },
      ),
    );
  }

  Widget _voices(
    BuildContext context,
    AudioCatalog catalog,
    AudioLibrary library,
  ) {
    final selectedId = context.select(
      (SettingsCubit cubit) => cubit.currentSettings.adhanVoiceId,
    );
    return ListView(
      key: ValueKey(_refresh),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            appText(
              context,
              'الأذان المدمج يعمل دائمًا بدون إنترنت. الأصوات الأخرى تُحمَّل مرة واحدة وتُحفظ على جهازك.',
              'The built-in adhan always works offline. Other voices download once and stay on your device.',
            ),
          ),
        ),
        for (final voice in catalog.adhanVoices)
          FutureBuilder<bool>(
            future: library.isAdhanInstalled(voice),
            builder: (context, installed) {
              final ready = installed.data ?? voice.isBundled;
              final progress = _progress[voice.id];
              final selected = voice.id == selectedId && ready;
              final bytes = library.downloadBytes(voice);
              return ListTile(
                selected: selected,
                leading: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(appText(context, voice.nameAr, voice.nameEn)),
                subtitle: Text(
                  voice.isBundled
                      ? appText(context, 'مدمج • بدون تحميل', 'Built in')
                      : ready
                      ? '${appText(context, 'محمّل', 'Downloaded')}${voice.credit == null ? '' : ' • ${voice.credit}'}'
                      : appText(
                          context,
                          'غير محمّل • ${_size(bytes)}',
                          'Not downloaded • ${_size(bytes)}',
                        ),
                ),
                trailing: progress != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              value: progress > 0 ? progress : null,
                              strokeWidth: 3,
                            ),
                          ),
                          IconButton(
                            tooltip: appText(context, 'إلغاء', 'Cancel'),
                            icon: const Icon(Icons.close),
                            onPressed: _tokens[voice.id]?.cancel,
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ready)
                            IconButton(
                              tooltip: appText(context, 'معاينة', 'Preview'),
                              icon: Icon(
                                _previewing == voice.id
                                    ? Icons.stop
                                    : Icons.play_arrow,
                              ),
                              onPressed: () => _preview(voice, library),
                            ),
                          if (!ready)
                            IconButton(
                              tooltip: appText(context, 'تحميل', 'Download'),
                              icon: const Icon(Icons.download),
                              onPressed: () => _download(voice, library),
                            ),
                          if (ready && !voice.isBundled)
                            IconButton(
                              tooltip: appText(context, 'حذف', 'Delete'),
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  _deleteVoice(voice, library, selected),
                            ),
                        ],
                      ),
                onTap: progress != null
                    ? null
                    : ready
                    ? () => _selectVoice(voice, library)
                    : () => _download(voice, library),
              );
            },
          ),
      ],
    );
  }

  Widget _reciters(
    BuildContext context,
    AudioCatalog catalog,
    AudioLibrary library,
  ) {
    final selected = catalog.reciter(_reciterId ?? defaultReciterId).id;
    return ListView(
      key: ValueKey(_refresh),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            appText(
              context,
              'تُبثّ التلاوة من الإنترنت، ويمكنك حفظ صفحات للاستماع بدون اتصال من شاشة المصحف.',
              'Recitation streams online. Save pages for offline listening from the Quran reader.',
            ),
          ),
        ),
        for (final reciter in catalog.reciters)
          FutureBuilder<int>(
            future: library.directorySize(library.recitationDir(reciter)),
            builder: (context, size) {
              final bytes = size.data ?? 0;
              return ListTile(
                selected: reciter.id == selected,
                leading: Icon(
                  reciter.id == selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(appText(context, reciter.nameAr, reciter.nameEn)),
                subtitle: Text(
                  bytes > 0
                      ? appText(
                          context,
                          'محفوظ على الجهاز: ${_size(bytes)}',
                          'Saved on device: ${_size(bytes)}',
                        )
                      : '${reciter.bitrate} kbps',
                ),
                trailing: bytes > 0
                    ? IconButton(
                        tooltip: appText(
                          context,
                          'حذف المحفوظ',
                          'Delete saved',
                        ),
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await library.deleteRecitation(reciter);
                          if (mounted) setState(() => _refresh++);
                        },
                      )
                    : null,
                onTap: () => _selectReciter(reciter),
              );
            },
          ),
      ],
    );
  }
}
