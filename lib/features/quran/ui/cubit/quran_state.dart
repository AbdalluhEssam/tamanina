part of 'quran_cubit.dart';

/// Captures the different fetching stages for Quran content.
enum QuranStatus {
  initial,
  loading,
  loaded,
  loadingSelection,
  selected,
  ayahSelected,
  error,
}

/// Immutable state for the [QuranCubit].
class QuranState extends Equatable {
  const QuranState({
    required this.status,
    required this.surahs,
    this.selectedSurah,
    this.selectedAyah,
    this.errorMessage,
  });

  /// Construct the initial idle state.
  factory QuranState.initial() {
    return const QuranState(
        status: QuranStatus.initial, surahs: <QuranEntity>[]);
  }

  final QuranStatus status;
  final List<QuranEntity> surahs;
  final QuranEntity? selectedSurah;
  final AyahModel? selectedAyah;
  final String? errorMessage;

  QuranState copyWith({
    QuranStatus? status,
    List<QuranEntity>? surahs,
    QuranEntity? selectedSurah,
    AyahModel? selectedAyah,
    String? errorMessage,
    bool resetError = false,
    bool clearSelectedSurah = false,
    bool clearSelectedAyah = false,
  }) {
    return QuranState(
      status: status ?? this.status,
      surahs: surahs ?? this.surahs,
      selectedSurah:
          clearSelectedSurah ? null : selectedSurah ?? this.selectedSurah,
      selectedAyah:
          clearSelectedAyah ? null : selectedAyah ?? this.selectedAyah,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        surahs,
        selectedSurah,
        selectedAyah,
        errorMessage,
      ];
}
