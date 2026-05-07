import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../model/quran_entity.dart';
import '../model/ayah_model.dart';
import '../model/last_read_model.dart';

/// Repository boundary for Quran data operations.
abstract class QuranRepository {
  /// Returns every surah bundled with ayahs.
  Future<Either<Failure, List<QuranEntity>>> getAllSurahs();

  /// Returns a specific surah by [id].
  Future<Either<Failure, QuranEntity>> getSurah(int surahNumber);

  /// Returns a specific ayah/verse
  Future<Either<Failure, String>> getVerse(int surahNumber, int verseNumber);

  /// Search in Quran
  Future<Either<Failure, List<QuranEntity>>> searchQuran(String query);

  /// Finds a single ayah inside a surah.
  Future<Either<AppException, AyahModel>> getAyah({
    required int surahId,
    required int ayahNumber,
  });

  /// Saves the last ayah that was interacted with.
  Future<Either<AppException, Unit>> saveLastRead({
    required LastReadModel lastRead,
  });

  /// Loads the last persisted ayah details.
  Future<Either<AppException, LastReadModel?>> getLastRead();

  /// Persists the playback position in milliseconds.
  Future<Either<AppException, Unit>> savePlaybackPosition({
    required Duration position,
  });

  /// Retrieves the last stored playback position.
  Future<Either<AppException, Duration?>> getPlaybackPosition();
}
