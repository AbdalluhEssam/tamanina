part of 'audio_cubit.dart';

/// Represents the different playback phases.
enum AudioStatus { initial, loading, ready, playing, paused, completed, error }

/// State model describing Quran audio playback.
class AudioState extends Equatable {
  const AudioState({
    required this.status,
    this.currentAyah,
    this.currentSurahId,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentWordIndex = -1,
    this.errorMessage,
  });

  /// Builds the default idle state.
  factory AudioState.initial() {
    return const AudioState(status: AudioStatus.initial);
  }

  final AudioStatus status;
  final AyahModel? currentAyah;
  final int? currentSurahId;
  final Duration position;
  final Duration duration;
  final int currentWordIndex;
  final String? errorMessage;

  AudioState copyWith({
    AudioStatus? status,
    AyahModel? currentAyah,
    int? currentSurahId,
    Duration? position,
    Duration? duration,
    int? currentWordIndex,
    String? errorMessage,
    bool resetError = false,
  }) {
    return AudioState(
      status: status ?? this.status,
      currentAyah: currentAyah ?? this.currentAyah,
      currentSurahId: currentSurahId ?? this.currentSurahId,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        currentAyah,
        currentSurahId,
        position,
        duration,
        currentWordIndex,
        errorMessage,
      ];
}
