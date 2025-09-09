import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../entities/quran_entity.dart';
import '../repositories/quran_repository.dart';

/// Use case للحصول على جميع السور
class GetAllSurahsUseCase implements UseCase<List<QuranEntity>, NoParams> {
  final QuranRepository repository;

  GetAllSurahsUseCase(this.repository);

  @override
  Future<Either<Failure, List<QuranEntity>>> call(NoParams params) async {
    return await repository.getAllSurahs();
  }
}

/// Use case للحصول على سورة معينة
class GetSurahUseCase implements UseCase<QuranEntity, GetSurahParams> {
  final QuranRepository repository;

  GetSurahUseCase(this.repository);

  @override
  Future<Either<Failure, QuranEntity>> call(GetSurahParams params) async {
    return await repository.getSurah(params.surahNumber);
  }
}

/// Use case للحصول على آية معينة
class GetVerseUseCase implements UseCase<VerseEntity, GetVerseParams> {
  final QuranRepository repository;

  GetVerseUseCase(this.repository);

  @override
  Future<Either<Failure, VerseEntity>> call(GetVerseParams params) async {
    return await repository.getVerse(params.surahNumber, params.verseNumber);
  }
}

/// Use case للبحث في القرآن
class SearchQuranUseCase implements UseCase<List<VerseEntity>, SearchParams> {
  final QuranRepository repository;

  SearchQuranUseCase(this.repository);

  @override
  Future<Either<Failure, List<VerseEntity>>> call(SearchParams params) async {
    return await repository.searchQuran(params.query);
  }
}

/// Use case للحصول على السور المفضلة
class GetFavoriteSurahsUseCase implements UseCase<List<QuranEntity>, NoParams> {
  final QuranRepository repository;

  GetFavoriteSurahsUseCase(this.repository);

  @override
  Future<Either<Failure, List<QuranEntity>>> call(NoParams params) async {
    return await repository.getFavoriteSurahs();
  }
}

/// Use case للحصول على الآيات المفضلة
class GetFavoriteVersesUseCase implements UseCase<List<VerseEntity>, NoParams> {
  final QuranRepository repository;

  GetFavoriteVersesUseCase(this.repository);

  @override
  Future<Either<Failure, List<VerseEntity>>> call(NoParams params) async {
    return await repository.getFavoriteVerses();
  }
}

/// Use case للحصول على الآيات المحفوظة
class GetBookmarkedVersesUseCase
    implements UseCase<List<VerseEntity>, NoParams> {
  final QuranRepository repository;

  GetBookmarkedVersesUseCase(this.repository);

  @override
  Future<Either<Failure, List<VerseEntity>>> call(NoParams params) async {
    return await repository.getBookmarkedVerses();
  }
}

/// Use case لتبديل حالة السورة المفضلة
class ToggleSurahFavoriteUseCase
    implements UseCase<bool, ToggleFavoriteParams> {
  final QuranRepository repository;

  ToggleSurahFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ToggleFavoriteParams params) async {
    return await repository.toggleSurahFavorite(params.surahNumber);
  }
}

/// Use case لتبديل حالة الآية المفضلة
class ToggleVerseFavoriteUseCase implements UseCase<bool, ToggleVerseParams> {
  final QuranRepository repository;

  ToggleVerseFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ToggleVerseParams params) async {
    return await repository.toggleVerseFavorite(
        params.surahNumber, params.verseNumber);
  }
}

/// Use case لتبديل حالة الآية المحفوظة
class ToggleVerseBookmarkUseCase implements UseCase<bool, ToggleVerseParams> {
  final QuranRepository repository;

  ToggleVerseBookmarkUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ToggleVerseParams params) async {
    return await repository.toggleVerseBookmark(
        params.surahNumber, params.verseNumber);
  }
}

/// Use case لتحديث آخر قراءة
class UpdateLastReadUseCase implements UseCase<bool, UpdateLastReadParams> {
  final QuranRepository repository;

  UpdateLastReadUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateLastReadParams params) async {
    return await repository.updateLastRead(
        params.surahNumber, params.verseNumber);
  }
}

/// Use case للحصول على إحصائيات القراءة
class GetReadingStatsUseCase implements UseCase<QuranStats, NoParams> {
  final QuranRepository repository;

  GetReadingStatsUseCase(this.repository);

  @override
  Future<Either<Failure, QuranStats>> call(NoParams params) async {
    return await repository.getReadingStats();
  }
}

// Parameters classes
class GetSurahParams {
  final int surahNumber;

  GetSurahParams({required this.surahNumber});
}

class GetVerseParams {
  final int surahNumber;
  final int verseNumber;

  GetVerseParams({required this.surahNumber, required this.verseNumber});
}

class SearchParams {
  final String query;

  SearchParams({required this.query});
}

class ToggleFavoriteParams {
  final int surahNumber;

  ToggleFavoriteParams({required this.surahNumber});
}

class ToggleVerseParams {
  final int surahNumber;
  final int verseNumber;

  ToggleVerseParams({required this.surahNumber, required this.verseNumber});
}

class UpdateLastReadParams {
  final int surahNumber;
  final int verseNumber;

  UpdateLastReadParams({required this.surahNumber, required this.verseNumber});
}
