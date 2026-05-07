import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../data/model/ayah_model.dart';
import '../../data/model/last_read_model.dart';
import '../../data/model/word_timing_model.dart';
import '../../data/repo/quran_repository.dart';

part 'audio_state.dart';

/// Coordinates Quran audio playback and word highlighting.
class AudioCubit extends Cubit<AudioState> {
  AudioCubit({required QuranRepository repository})
      : _repository = repository,
        _audioPlayer = AudioPlayer(),
        super(AudioState.initial()) {
    _bindStreams();
  }

  final QuranRepository _repository;
  final AudioPlayer _audioPlayer;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  Duration _lastPersistedPosition = Duration.zero;

  /// Loads audio for the given [surahId] and [ayahNumber].
  Future<void> loadAyah({
    required int surahId,
    required int ayahNumber,
    bool persistLastRead = true,
  }) async {
    emit(state.copyWith(status: AudioStatus.loading));

    final Either<AppException, AyahModel> result = await _repository.getAyah(
      surahId: surahId,
      ayahNumber: ayahNumber,
    );

    await result.fold(
      (failure) async {
        emit(state.copyWith(
            status: AudioStatus.error, errorMessage: failure.message));
      },
      (ayah) async {
        try {
          await _audioPlayer.setUrl(ayah.audioUrl);
          final duration = _audioPlayer.duration ?? Duration.zero;
          _lastPersistedPosition = Duration.zero;
          if (persistLastRead) {
            await _repository.saveLastRead(
              lastRead: LastReadModel(surahId: surahId, ayahNumber: ayahNumber),
            );
          }
          emit(
            state.copyWith(
              status: AudioStatus.ready,
              currentAyah: ayah,
              currentSurahId: surahId,
              duration: duration,
              position: Duration.zero,
              currentWordIndex: ayah.wordTimings.isEmpty ? -1 : 0,
              resetError: true,
            ),
          );
        } on PlayerException catch (error) {
          emit(
            state.copyWith(
              status: AudioStatus.error,
              errorMessage: error.message ?? 'Failed to load audio',
            ),
          );
        } catch (error) {
          emit(
            state.copyWith(
              status: AudioStatus.error,
              errorMessage: error.toString(),
            ),
          );
        }
      },
    );
  }

  /// Restores the last ayah and playback position if available.
  Future<void> restoreLastSession() async {
    emit(state.copyWith(status: AudioStatus.loading));

    final lastReadResult = await _repository.getLastRead();
    final lastPositionResult = await _repository.getPlaybackPosition();

    AppException? failure;
    LastReadModel? lastRead;
    Duration? lastPosition;

    lastReadResult.fold(
        (error) => failure = error, (value) => lastRead = value);
    lastPositionResult.fold(
        (error) => failure = error, (value) => lastPosition = value);

    if (failure != null) {
      emit(
        state.copyWith(
          status: AudioStatus.error,
          errorMessage: failure!.message,
        ),
      );
      return;
    }

    if (lastRead == null) {
      emit(AudioState.initial());
      return;
    }

    await loadAyah(
      surahId: lastRead!.surahId,
      ayahNumber: lastRead!.ayahNumber,
      persistLastRead: false,
    );

    if (lastPosition != null &&
        lastPosition!.inMilliseconds < state.duration.inMilliseconds) {
      final position = lastPosition!;
      await _audioPlayer.seek(position);
      emit(
        state.copyWith(
          position: position,
          currentWordIndex: _calculateWordIndex(
            state.currentAyah,
            position,
          ),
        ),
      );
    }
  }

  /// Starts or resumes playback.
  Future<void> play() async {
    if (state.currentAyah == null) {
      return;
    }
    await _audioPlayer.play();
    emit(state.copyWith(status: AudioStatus.playing));
  }

  /// Pauses playback.
  Future<void> pause() async {
    await _audioPlayer.pause();
    emit(state.copyWith(status: AudioStatus.paused));
  }

  /// Stops playback and resets position.
  Future<void> stop() async {
    await _audioPlayer.stop();
    emit(state.copyWith(
      status: AudioStatus.ready,
      position: Duration.zero,
      currentWordIndex: state.currentAyah?.wordTimings.isEmpty ?? true ? -1 : 0,
    ));
  }

  /// Seeks to a specific [position].
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    emit(state.copyWith(position: position));
  }

  /// Toggles play/pause according to the current status.
  Future<void> toggle() async {
    if (state.status == AudioStatus.playing) {
      await pause();
    } else {
      await play();
    }
  }

  @override
  Future<void> close() async {
    await _positionSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _audioPlayer.dispose();
    await super.close();
  }

  void _bindStreams() {
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (state.currentAyah == null) {
        return;
      }
      final ayah = state.currentAyah!;
      final index = _calculateWordIndex(ayah, position);
      if (index != state.currentWordIndex || position != state.position) {
        emit(state.copyWith(
          position: position,
          currentWordIndex: index,
        ));
      }
      if ((position - _lastPersistedPosition).inMilliseconds.abs() > 2000) {
        _lastPersistedPosition = position;
        unawaited(
          _repository.savePlaybackPosition(position: position),
        );
      }
    });

    _playerStateSubscription =
        _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        emit(state.copyWith(status: AudioStatus.completed));
      } else if (playerState.processingState == ProcessingState.ready &&
          playerState.playing) {
        emit(state.copyWith(status: AudioStatus.playing));
      } else if (playerState.playing) {
        emit(state.copyWith(status: AudioStatus.playing));
      } else {
        emit(state.copyWith(status: AudioStatus.paused));
      }
    });
  }

  int _calculateWordIndex(AyahModel? ayah, Duration position) {
    if (ayah == null || ayah.wordTimings.isEmpty) {
      return -1;
    }
    final List<WordTimingModel> words = ayah.wordTimings;
    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      final start = word.start;
      final end = start + word.duration;
      if (position >= start && position < end) {
        return i;
      }
    }
    if (position >= words.last.start) {
      return words.length - 1;
    }
    return 0;
  }
}
