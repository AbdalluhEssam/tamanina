import 'package:flutter/material.dart';

import '../../data/model/ayah_model.dart';
import '../cubit/audio_cubit.dart';
import 'highlight_text.dart';

/// List tile representing a single ayah with play/pause controls.
class AyahTile extends StatelessWidget {
  const AyahTile({
    super.key,
    required this.ayah,
    required this.audioState,
    required this.onPlayPressed,
  });

  final AyahModel ayah;
  final AudioState audioState;
  final VoidCallback onPlayPressed;

  bool get _isCurrentAyah =>
      audioState.currentAyah?.number == ayah.number &&
      audioState.status != AudioStatus.initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaying =
        _isCurrentAyah && audioState.status == AudioStatus.playing;

    return Card(
      elevation: isPlaying ? 6 : 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    ayah.number.toString(),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: HighlightText(
                    text: ayah.text,
                    currentWordIndex:
                        _isCurrentAyah ? audioState.currentWordIndex : -1,
                    activeStyle: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    inactiveStyle: theme.textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton.filled(
                onPressed: onPlayPressed,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
