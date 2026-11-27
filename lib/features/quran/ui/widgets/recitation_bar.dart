import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/tamanina_ui.dart';
import '../../data/services/recitation_playback.dart';

/// Shows the verse being recited with ayah-by-ayah controls.
class RecitationBar extends StatelessWidget {
  const RecitationBar({
    required this.player,
    required this.surahName,
    required this.ayah,
    required this.verseText,
    required this.repeat,
    required this.continuous,
    required this.onRepeat,
    required this.onContinuous,
    required this.onStop,
    super.key,
  });

  final RecitationPlayback player;
  final String surahName;
  final int ayah;
  final String verseText;
  final int repeat;
  final bool continuous;
  final VoidCallback onRepeat;
  final VoidCallback onContinuous;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appText(
                  context,
                  '$surahName • الآية $ayah',
                  '$surahName • Verse $ayah',
                ),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 2),
              Text(
                verseText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  height: 1.7,
                ),
              ),
              StreamBuilder<PlaybackState>(
                stream: player.playbackState,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? true;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: appText(
                          context,
                          'الآية السابقة',
                          'Previous verse',
                        ),
                        icon: const Icon(Icons.skip_previous),
                        onPressed: player.skipToPrevious,
                      ),
                      IconButton.filledTonal(
                        tooltip: playing
                            ? appText(context, 'إيقاف مؤقت', 'Pause')
                            : appText(context, 'تشغيل', 'Play'),
                        icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                        onPressed: playing ? player.pause : player.play,
                      ),
                      IconButton(
                        tooltip: appText(
                          context,
                          'الآية التالية',
                          'Next verse',
                        ),
                        icon: const Icon(Icons.skip_next),
                        onPressed: player.skipToNext,
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(Icons.repeat, size: 18),
                        label: Text('$repeat×'),
                        tooltip: appText(
                          context,
                          'تكرار كل آية',
                          'Repeat each verse',
                        ),
                        onPressed: onRepeat,
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        label: Text(appText(context, 'تتابع', 'Continue')),
                        tooltip: appText(
                          context,
                          'الانتقال تلقائيًا للصفحة التالية',
                          'Move on to the next page automatically',
                        ),
                        selected: continuous,
                        onSelected: (_) => onContinuous(),
                      ),
                      IconButton(
                        tooltip: appText(
                          context,
                          'إيقاف التلاوة',
                          'Stop recitation',
                        ),
                        icon: const Icon(Icons.stop),
                        onPressed: onStop,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
