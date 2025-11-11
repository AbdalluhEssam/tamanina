import 'package:dartz/dartz.dart';
import 'package:quran_sharif/quran_sharif.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/model/quran_entity.dart';
import '../../data/repo/quran_repository.dart' as domain;
import '../datasources/quran_local_datasource.dart';
import '../model/quran_model.dart';
import '../model/ayah_model.dart';
import '../model/last_read_model.dart';

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
  Future<Either<Failure, String>> getVerse(
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

      return Right(ayahData.text);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Helper method to get full verse entity (not in interface)
  Future<Either<Failure, VerseEntity>> _getVerseEntity(
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
  Future<Either<Failure, List<QuranEntity>>> searchQuran(String query) async {
    try {
      final matchingSurahs = <QuranEntity>[];
      final surahsData = Quran.getAllSurah();

      for (final surahData in surahsData) {
        final surahNumber = surahData.number;
        bool hasMatch = false;
        final verses = <VerseEntity>[];

        for (final ayahData in surahData.ayahs) {
          if (ayahData.text.contains(query)) {
            hasMatch = true;
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

        // If this surah has matching verses, include it
        if (hasMatch) {
          final lastRead = await localDataSource.getLastReadVerse(surahNumber);
          final isFavorite = await localDataSource.isSurahFavorite(surahNumber);

          matchingSurahs.add(QuranModel(
            surahNumber: surahNumber,
            surahNameArabic: surahData.name,
            surahNameEnglish: surahData.englishName,
            surahNameTransliteration: surahData.englishNameTranslation,
            totalVerses: surahData.ayahs.length,
            revelationType:
                surahData.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
            revelationOrder: surahNumber,
            surahMeaning: surahData.englishNameTranslation,
            verses: verses,
            isFavorite: isFavorite,
            lastReadVerse: lastRead,
            lastReadAt: lastRead > 0
                ? await localDataSource.getLastReadTime(surahNumber)
                : null,
          ).toEntity());
        }
      }

      return Right(matchingSurahs);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Extra method not in interface - provides favorite surahs
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

  // Extra method not in interface - provides favorite verses
  Future<Either<Failure, List<VerseEntity>>> getFavoriteVerses() async {
    try {
      final favoriteVerses = await localDataSource.getFavoriteVerses();
      final verses = <VerseEntity>[];

      for (final verseRef in favoriteVerses) {
        final parts = verseRef.split(':');
        final surahNumber = int.parse(parts[0]);
        final verseNumber = int.parse(parts[1]);

        final result = await _getVerseEntity(surahNumber, verseNumber);
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

  // Extra method not in interface - provides bookmarked verses
  Future<Either<Failure, List<VerseEntity>>> getBookmarkedVerses() async {
    try {
      final bookmarkedVerses = await localDataSource.getBookmarkedVerses();
      final verses = <VerseEntity>[];

      for (final verseRef in bookmarkedVerses) {
        final parts = verseRef.split(':');
        final surahNumber = int.parse(parts[0]);
        final verseNumber = int.parse(parts[1]);

        final result = await _getVerseEntity(surahNumber, verseNumber);
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

  // Extra method not in interface - toggles surah favorite status
  Future<Either<Failure, bool>> toggleSurahFavorite(int surahNumber) async {
    try {
      await localDataSource.toggleSurahFavorite(surahNumber);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Extra method not in interface - toggles verse favorite status
  Future<Either<Failure, bool>> toggleVerseFavorite(
      int surahNumber, int verseNumber) async {
    try {
      await localDataSource.toggleVerseFavorite(surahNumber, verseNumber);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Extra method not in interface - toggles verse bookmark status
  Future<Either<Failure, bool>> toggleVerseBookmark(
      int surahNumber, int verseNumber) async {
    try {
      await localDataSource.toggleVerseBookmark(surahNumber, verseNumber);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Extra method not in interface - updates last read position
  Future<Either<Failure, bool>> updateLastRead(
      int surahNumber, int verseNumber) async {
    try {
      await localDataSource.updateLastRead(surahNumber, verseNumber);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Extra method not in interface - gets reading statistics
  Future<Either<Failure, QuranStats>> getReadingStats() async {
    try {
      final stats = await localDataSource.getReadingStats();
      return Right(stats);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Extra method not in interface - adds note to verse
  Future<Either<Failure, bool>> addVerseNote(
      int surahNumber, int verseNumber, String note) async {
    try {
      await localDataSource.addVerseNote(surahNumber, verseNumber, note);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Extra method not in interface - adds tag to verse
  Future<Either<Failure, bool>> addVerseTag(
      int surahNumber, int verseNumber, String tag) async {
    try {
      await localDataSource.addVerseTag(surahNumber, verseNumber, tag);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Extra method not in interface - removes tag from verse
  Future<Either<Failure, bool>> removeVerseTag(
      int surahNumber, int verseNumber, String tag) async {
    try {
      await localDataSource.removeVerseTag(surahNumber, verseNumber, tag);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Extra method not in interface - gets surah with translation
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

  @override
  Future<Either<AppException, AyahModel>> getAyah({
    required int surahId,
    required int ayahNumber,
  }) async {
    try {
      final surahData = Quran.getSurahById(id: surahId);

      if (surahData == null) {
        return Left(CacheException('Surah not found'));
      }

      final ayahData = surahData.ayahs.firstWhere(
        (ayah) => ayah.numberInSurah == ayahNumber,
        orElse: () => throw Exception('Ayah not found'),
      );

      final ayahModel = AyahModel(
        number: ayahNumber,
        text: ayahData.text,
        audioUrl: '', // quran_sharif doesn't provide audio URLs
        wordTimings: [], // Would need word timing data
      );

      return Right(ayahModel);
    } catch (e) {
      return Left(CacheException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, Unit>> saveLastRead({
    required LastReadModel lastRead,
  }) async {
    try {
      await localDataSource.updateLastRead(
        lastRead.surahId,
        lastRead.ayahNumber,
      );
      return const Right(unit);
    } catch (e) {
      return Left(CacheException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, LastReadModel?>> getLastRead() async {
    try {
      // Get the most recent read surah
      DateTime? mostRecentTime;
      int? mostRecentSurah;
      int? mostRecentAyah;

      for (int i = 1; i <= 114; i++) {
        final lastReadVerse = await localDataSource.getLastReadVerse(i);
        if (lastReadVerse > 0) {
          final readTime = await localDataSource.getLastReadTime(i);
          if (readTime != null &&
              (mostRecentTime == null || readTime.isAfter(mostRecentTime))) {
            mostRecentTime = readTime;
            mostRecentSurah = i;
            mostRecentAyah = lastReadVerse;
          }
        }
      }

      if (mostRecentSurah != null && mostRecentAyah != null) {
        return Right(LastReadModel(
          surahId: mostRecentSurah,
          ayahNumber: mostRecentAyah,
        ));
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, Unit>> savePlaybackPosition({
    required Duration position,
  }) async {
    try {
      // Store playback position using SharedPreferences through a helper method
      // For now, we'll use a simple approach
      return const Right(unit);
    } catch (e) {
      return Left(CacheException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, Duration?>> getPlaybackPosition() async {
    try {
      // Retrieve playback position
      // For now, return null as placeholder
      return const Right(null);
    } catch (e) {
      return Left(CacheException(e.toString()));
    }
  }
}
