import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../model/quran_entity.dart';
import '../repo/quran_repository.dart';

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
class GetVerseUseCase implements UseCase<String, GetVerseParams> {
  final QuranRepository repository;

  GetVerseUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(GetVerseParams params) async {
    return await repository.getVerse(params.surahNumber, params.verseNumber);
  }
}

/// Use case للبحث في القرآن
class SearchQuranUseCase implements UseCase<List<QuranEntity>, SearchParams> {
  final QuranRepository repository;

  SearchQuranUseCase(this.repository);

  @override
  Future<Either<Failure, List<QuranEntity>>> call(SearchParams params) async {
    return await repository.searchQuran(params.query);
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
