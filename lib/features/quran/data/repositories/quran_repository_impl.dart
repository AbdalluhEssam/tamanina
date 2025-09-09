import 'package:dartz/dartz.dart';
import 'package:quran_sharif/quran_sharif.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/quran_entity.dart';
import '../../domain/repositories/quran_repository.dart' as domain;
import '../datasources/quran_local_datasource.dart';
import '../models/quran_model.dart';

class QuranRepositoryImpl implements domain.QuranRepository {
  final QuranLocalDataSource localDataSource;

  QuranRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<QuranEntity>>> getAllSurahs() async {
    try {
      final surahs = <QuranEntity>[];
      final surahsData = Quran.getAllSurah();

      for (final surahData in surahsData) {
        final surahNumber = surahData.number;
        final lastRead = await localDataSource.getLastReadVerse(surahNumber);
        final isFavorite = await localDataSource.isSurahFavorite(surahNumber);

        surahs.add(QuranModel(
          surahNumber: surahNumber,
          surahNameArabic: surahData.name,
          surahNameEnglish: surahData.englishName,
          surahNameTransliteration: surahData.englishNameTranslation,
          totalVerses: surahData.ayahs.length,
          revelationType:
              surahData.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
          revelationOrder:
              surahNumber, // quran_sharif doesn't provide revelation order, using number
          surahMeaning: surahData.englishNameTranslation,
          isFavorite: isFavorite,
          lastReadVerse: lastRead,
          lastReadAt: lastRead > 0
              ? await localDataSource.getLastReadTime(surahNumber)
              : null,
        ).toEntity());
      }

      return Right(surahs);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuranEntity>> getSurah(int surahNumber) async {
    try {
      final surahData = Quran.getSurahById(id: surahNumber);

      if (surahData == null) {
        return Left(CacheFailure('Surah not found'));
      }

      final verses = <VerseEntity>[];

      // Get verses from surah data
      for (final ayahData in surahData.ayahs) {
        final verseNumber = ayahData.numberInSurah;
        final isFavorite =
            await localDataSource.isVerseFavorite(surahNumber, verseNumber);
        final isBookmarked =
            await localDataSource.isVerseBookmarked(surahNumber, verseNumber);
        final note =
            await localDataSource.getVerseNote(surahNumber, verseNumber);
        final tags =
            await localDataSource.getVerseTags(surahNumber, verseNumber);

        verses.add(VerseModel(
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          arabicText: ayahData.text,
          transliteration: '', // quran_sharif doesn't provide transliteration
          translation: '', // Would need translation integration
          isFavorite: isFavorite,
          isBookmarked: isBookmarked,
          personalNote: note,
          tags: tags,
        ).toEntity());
      }

      final lastRead = await localDataSource.getLastReadVerse(surahNumber);
      final isFavorite = await localDataSource.isSurahFavorite(surahNumber);
      final lastReadTime = lastRead > 0
          ? await localDataSource.getLastReadTime(surahNumber)
          : null;

      final surah = QuranModel(
        surahNumber: surahNumber,
        surahNameArabic: surahData.name,
        surahNameEnglish: surahData.englishName,
        surahNameTransliteration: surahData.englishNameTranslation,
        totalVerses: surahData.ayahs.length,
        revelationType: surahData.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
        revelationOrder: surahNumber,
        surahMeaning: surahData.englishNameTranslation,
        verses: verses,
        isFavorite: isFavorite,
        lastReadVerse: lastRead,
        lastReadAt: lastReadTime,
      ).toEntity();

      return Right(surah);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerseEntity>> getVerse(
      int surahNumber, int verseNumber) async {
    try {
      final surahData = Quran.getSurahById(id: surahNumber);

      if (surahData == null) {
        return Left(CacheFailure('Surah not found'));
      }

      final ayahData = surahData.ayahs.firstWhere(
        (ayah) => ayah.numberInSurah == verseNumber,
        orElse: () => throw Exception('Verse not found'),
      );

      final isFavorite =
          await localDataSource.isVerseFavorite(surahNumber, verseNumber);
      final isBookmarked =
          await localDataSource.isVerseBookmarked(surahNumber, verseNumber);
      final note = await localDataSource.getVerseNote(surahNumber, verseNumber);
      final tags = await localDataSource.getVerseTags(surahNumber, verseNumber);

      final verse = VerseModel(
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        arabicText: ayahData.text,
        transliteration: '',
        translation: '',
        isFavorite: isFavorite,
        isBookmarked: isBookmarked,
        personalNote: note,
        tags: tags,
      ).toEntity();

      return Right(verse);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VerseEntity>>> searchQuran(String query) async {
    try {
      final verses = <VerseEntity>[];
      final surahsData = Quran.getAllSurah();

      for (final surahData in surahsData) {
        final surahNumber = surahData.number;

        for (final ayahData in surahData.ayahs) {
          if (ayahData.text.contains(query)) {
            final verseNumber = ayahData.numberInSurah;
            final isFavorite =
                await localDataSource.isVerseFavorite(surahNumber, verseNumber);
            final isBookmarked = await localDataSource.isVerseBookmarked(
                surahNumber, verseNumber);
            final note =
                await localDataSource.getVerseNote(surahNumber, verseNumber);
            final tags =
                await localDataSource.getVerseTags(surahNumber, verseNumber);

            verses.add(VerseModel(
              surahNumber: surahNumber,
              verseNumber: verseNumber,
              arabicText: ayahData.text,
              transliteration: '',
              translation: '',
              isFavorite: isFavorite,
              isBookmarked: isBookmarked,
              personalNote: note,
              tags: tags,
            ).toEntity());
          }
        }
      }

      return Right(verses);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuranEntity>>> getFavoriteSurahs() async {
    try {
      final favoriteSurahs = await localDataSource.getFavoriteSurahs();
      final surahs = <QuranEntity>[];

      for (final surahNumber in favoriteSurahs) {
        final result = await getSurah(surahNumber);
        result.fold(
          (failure) => throw Exception(failure.toString()),
          (surah) => surahs.add(surah),
        );
      }

      return Right(surahs);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VerseEntity>>> getFavoriteVerses() async {
    try {
      final favoriteVerses = await localDataSource.getFavoriteVerses();
      final verses = <VerseEntity>[];

      for (final verseRef in favoriteVerses) {
        final parts = verseRef.split(':');
        final surahNumber = int.parse(parts[0]);
        final verseNumber = int.parse(parts[1]);

        final result = await getVerse(surahNumber, verseNumber);
        result.fold(
          (failure) => throw Exception(failure.toString()),
          (verse) => verses.add(verse),
        );
      }

      return Right(verses);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VerseEntity>>> getBookmarkedVerses() async {
    try {
      final bookmarkedVerses = await localDataSource.getBookmarkedVerses();
      final verses = <VerseEntity>[];

      for (final verseRef in bookmarkedVerses) {
        final parts = verseRef.split(':');
        final surahNumber = int.parse(parts[0]);
        final verseNumber = int.parse(parts[1]);

        final result = await getVerse(surahNumber, verseNumber);
        result.fold(
          (failure) => throw Exception(failure.toString()),
          (verse) => verses.add(verse),
        );
      }

      return Right(verses);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleSurahFavorite(int surahNumber) async {
    try {
      await localDataSource.toggleSurahFavorite(surahNumber);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleVerseFavorite(
      int surahNumber, int verseNumber) async {
    try {
      await localDataSource.toggleVerseFavorite(surahNumber, verseNumber);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleVerseBookmark(
      int surahNumber, int verseNumber) async {
    try {
      await localDataSource.toggleVerseBookmark(surahNumber, verseNumber);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateLastRead(
      int surahNumber, int verseNumber) async {
    try {
      await localDataSource.updateLastRead(surahNumber, verseNumber);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuranStats>> getReadingStats() async {
    try {
      final stats = await localDataSource.getReadingStats();
      return Right(stats);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> addVerseNote(
      int surahNumber, int verseNumber, String note) async {
    try {
      await localDataSource.addVerseNote(surahNumber, verseNumber, note);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> addVerseTag(
      int surahNumber, int verseNumber, String tag) async {
    try {
      await localDataSource.addVerseTag(surahNumber, verseNumber, tag);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeVerseTag(
      int surahNumber, int verseNumber, String tag) async {
    try {
      await localDataSource.removeVerseTag(surahNumber, verseNumber, tag);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuranEntity>> getSurahWithTranslation(
      int surahNumber, String language) async {
    try {
      // This would be implemented with specific translation support
      // For now, return the regular surah
      return await getSurah(surahNumber);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
