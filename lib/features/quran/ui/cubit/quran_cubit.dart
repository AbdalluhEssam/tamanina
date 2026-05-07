import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/model/ayah_model.dart';
import '../../data/model/quran_entity.dart';
import '../../data/repo/quran_repository.dart';

part 'quran_state.dart';

/// Provides Quran data for the UI layer.
class QuranCubit extends Cubit<QuranState> {
  QuranCubit({required QuranRepository repository})
      : _repository = repository,
        super(QuranState.initial());

  final QuranRepository _repository;

  /// Fetches all surahs from the repository.
  Future<void> loadSurahs() async {
    emit(state.copyWith(status: QuranStatus.loading));
    final result = await _repository.getAllSurahs();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: QuranStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (surahs) => emit(
        state.copyWith(
          status: QuranStatus.loaded,
          surahs: surahs,
          resetError: true,
        ),
      ),
    );
  }

  /// Selects a specific surah for rendering in the UI.
  Future<void> selectSurah(int surahNumber) async {
    emit(state.copyWith(status: QuranStatus.loadingSelection));
    final result = await _repository.getSurah(surahNumber);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: QuranStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (surah) => emit(
        state.copyWith(
          status: QuranStatus.selected,
          selectedSurah: surah,
          clearSelectedAyah: true,
          resetError: true,
        ),
      ),
    );
  }

  /// Retrieves an ayah to display or play.
  Future<void> selectAyah({
    required int surahId,
    required int ayahNumber,
  }) async {
    emit(state.copyWith(status: QuranStatus.loadingSelection));
    final result = await _repository.getAyah(
      surahId: surahId,
      ayahNumber: ayahNumber,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: QuranStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (ayah) => emit(
        state.copyWith(
          status: QuranStatus.ayahSelected,
          selectedAyah: ayah,
          resetError: true,
        ),
      ),
    );
  }
}
