import 'package:flutter/material.dart';

import '../cubit/audio_cubit.dart';

/// Reusable control bar for Quran audio playback.
class AudioControlBar extends StatelessWidget {
  const AudioControlBar({
    super.key,
    required this.audioState,
    required this.onPlayPause,
    required this.onStop,
    required this.onSeek,
  });

  final AudioState audioState;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final ValueChanged<Duration> onSeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final position = audioState.position.inMilliseconds.toDouble();
    final duration = audioState.duration.inMilliseconds.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Slider(
          value: duration == 0 ? 0 : position.clamp(0, duration),
          min: 0,
          max: duration == 0 ? 1 : duration,
          onChanged: duration == 0
              ? null
              : (value) => onSeek(Duration(milliseconds: value.toInt())),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(audioState.position),
                style: theme.textTheme.bodySmall),
            Text(_formatDuration(audioState.duration),
                style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onStop,
              icon: const Icon(Icons.stop),
            ),
            const SizedBox(width: 24),
            FilledButton.icon(
              onPressed: onPlayPause,
              icon: Icon(
                audioState.status == AudioStatus.playing
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
              label: Text(
                audioState.status == AudioStatus.playing
                    ? 'إيقاف مؤقت'
                    : 'تشغيل',
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
