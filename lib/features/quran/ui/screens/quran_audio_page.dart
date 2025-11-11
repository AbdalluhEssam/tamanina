import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/ayah_model.dart';
import '../cubit/audio_cubit.dart';
import '../cubit/quran_cubit.dart';
import '../widgets/audio_control_bar.dart';
import '../widgets/ayah_tile.dart';
import '../widgets/highlight_text.dart';

/// Detailed Quran page with audio playback and word highlighting.
class QuranAudioPage extends StatefulWidget {
  const QuranAudioPage({super.key, required this.surahId});

  final int surahId;

  @override
  State<QuranAudioPage> createState() => _QuranAudioPageState();
}

class _QuranAudioPageState extends State<QuranAudioPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranCubit>().selectSurah(widget.surahId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<QuranCubit, QuranState>(
          builder: (context, state) {
            return Text(
                state.selectedSurah?.surahNameArabic ?? 'القرآن الكريم');
          },
        ),
        actions: [
          IconButton(
            tooltip: 'استرجاع آخر تلاوة',
            onPressed: () async {
              final audioCubit = context.read<AudioCubit>();
              await audioCubit.restoreLastSession();
              final restoredAyah = audioCubit.state.currentAyah;
              if (restoredAyah != null &&
                  audioCubit.state.currentSurahId == widget.surahId) {
                // sync selection with Quran cubit to update highlights list
                context.read<QuranCubit>().selectAyah(
                      surahId: widget.surahId,
                      ayahNumber: restoredAyah.number,
                    );
              }
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<QuranCubit, QuranState>(
            listenWhen: (prev, current) =>
                prev.selectedAyah != current.selectedAyah &&
                current.selectedAyah != null,
            listener: (context, state) async {
              final ayah = state.selectedAyah!;
              final audioCubit = context.read<AudioCubit>();
              final currentAyah = audioCubit.state.currentAyah;
              final currentSurahId = audioCubit.state.currentSurahId;
              if (currentAyah?.number == ayah.number &&
                  currentSurahId == widget.surahId &&
                  audioCubit.state.status != AudioStatus.error) {
                return;
              }
              await audioCubit.loadAyah(
                surahId: widget.surahId,
                ayahNumber: ayah.number,
              );
              if (audioCubit.state.status == AudioStatus.ready ||
                  audioCubit.state.status == AudioStatus.paused) {
                await audioCubit.play();
              }
            },
          ),
          BlocListener<AudioCubit, AudioState>(
            listenWhen: (previous, current) =>
                current.status == AudioStatus.error &&
                current.errorMessage != null,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            },
          ),
        ],
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<AudioCubit, AudioState>(
                builder: (context, audioState) {
                  if (audioState.currentAyah == null) {
                    return const Text(
                      'اختر آية لبدء التلاوة',
                      textAlign: TextAlign.center,
                    );
                  }
                  return HighlightSection(audioState: audioState);
                },
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<AudioCubit, AudioState>(
                builder: (context, audioState) {
                  return AudioControlBar(
                    audioState: audioState,
                    onPlayPause: () => context.read<AudioCubit>().toggle(),
                    onStop: () => context.read<AudioCubit>().stop(),
                    onSeek: (position) =>
                        context.read<AudioCubit>().seek(position),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<QuranCubit, QuranState>(
                builder: (context, state) {
                  if (state.status == QuranStatus.loadingSelection ||
                      state.status == QuranStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == QuranStatus.error) {
                    return Center(
                      child: Text(state.errorMessage ?? 'حدث خطأ غير متوقع'),
                    );
                  }
                  final surah = state.selectedSurah;
                  if (surah == null) {
                    return const Center(child: Text('جاري تحميل السورة...'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: surah.verses.length,
                    itemBuilder: (context, index) {
                      final verse = surah.verses[index];
                      // Convert VerseEntity to AyahModel for the widget
                      final ayah = AyahModel(
                        number: verse.verseNumber,
                        text: verse.arabicText,
                        audioUrl: verse.audioUrl,
                        wordTimings: const [], // TODO: Add word timings if needed
                      );
                      return BlocBuilder<AudioCubit, AudioState>(
                        builder: (context, audioState) {
                          return AyahTile(
                            ayah: ayah,
                            audioState: audioState,
                            onPlayPressed: () {
                              context.read<QuranCubit>().selectAyah(
                                    surahId: widget.surahId,
                                    ayahNumber: verse.verseNumber,
                                  );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Separate widget to highlight the active ayah.
class HighlightSection extends StatelessWidget {
  const HighlightSection({super.key, required this.audioState});

  final AudioState audioState;

  @override
  Widget build(BuildContext context) {
    final ayah = audioState.currentAyah!;
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          'الآية ${ayah.number}',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: HighlightText(
              text: ayah.text,
              currentWordIndex: audioState.currentWordIndex,
              activeStyle: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              ),
              inactiveStyle: theme.textTheme.headlineMedium,
            ),
          ),
        ),
      ],
    );
  }
}
