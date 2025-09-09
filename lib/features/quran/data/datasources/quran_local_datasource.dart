import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/quran_entity.dart';

abstract class QuranLocalDataSource {
  /// الحصول على آخر آية مقروءة للسورة
  Future<int> getLastReadVerse(int surahNumber);

  /// الحصول على وقت آخر قراءة للسورة
  Future<DateTime?> getLastReadTime(int surahNumber);

  /// تحديث آخر قراءة
  Future<void> updateLastRead(int surahNumber, int verseNumber);

  /// التحقق من كون السورة مفضلة
  Future<bool> isSurahFavorite(int surahNumber);

  /// التحقق من كون الآية مفضلة
  Future<bool> isVerseFavorite(int surahNumber, int verseNumber);

  /// التحقق من كون الآية محفوظة
  Future<bool> isVerseBookmarked(int surahNumber, int verseNumber);

  /// تبديل حالة السورة المفضلة
  Future<void> toggleSurahFavorite(int surahNumber);

  /// تبديل حالة الآية المفضلة
  Future<void> toggleVerseFavorite(int surahNumber, int verseNumber);

  /// تبديل حالة الآية المحفوظة
  Future<void> toggleVerseBookmark(int surahNumber, int verseNumber);

  /// الحصول على السور المفضلة
  Future<List<int>> getFavoriteSurahs();

  /// الحصول على الآيات المفضلة
  Future<List<String>> getFavoriteVerses();

  /// الحصول على الآيات المحفوظة
  Future<List<String>> getBookmarkedVerses();

  /// الحصول على ملاحظة الآية
  Future<String?> getVerseNote(int surahNumber, int verseNumber);

  /// إضافة ملاحظة للآية
  Future<void> addVerseNote(int surahNumber, int verseNumber, String note);

  /// الحصول على علامات الآية
  Future<List<String>> getVerseTags(int surahNumber, int verseNumber);

  /// إضافة علامة للآية
  Future<void> addVerseTag(int surahNumber, int verseNumber, String tag);

  /// حذف علامة من الآية
  Future<void> removeVerseTag(int surahNumber, int verseNumber, String tag);

  /// الحصول على إحصائيات القراءة
  Future<QuranStats> getReadingStats();

  /// حفظ الصفحة الحالية
  Future<void> saveCurrentPage(int pageNumber);

  /// الحصول على آخر صفحة محفوظة
  Future<int> getCurrentPage();

  /// حفظ موضع القراءة في الصفحة
  Future<void> savePageReadingPosition(int pageNumber, double scrollPosition);

  /// الحصول على موضع القراءة في الصفحة
  Future<double> getPageReadingPosition(int pageNumber);
}

class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  final SharedPreferences sharedPreferences;

  QuranLocalDataSourceImpl({required this.sharedPreferences});

  // Keys for SharedPreferences
  static const String _lastReadPrefix = 'last_read_';
  static const String _lastReadTimePrefix = 'last_read_time_';
  static const String _favoriteSurahsKey = 'favorite_surahs';
  static const String _favoriteVersesKey = 'favorite_verses';
  static const String _bookmarkedVersesKey = 'bookmarked_verses';
  static const String _verseNotePrefix = 'verse_note_';
  static const String _verseTagsPrefix = 'verse_tags_';
  static const String _currentPageKey = 'current_mushaf_page';
  static const String _pagePositionPrefix = 'page_position_';

  @override
  Future<int> getLastReadVerse(int surahNumber) async {
    return sharedPreferences.getInt('$_lastReadPrefix$surahNumber') ?? 0;
  }

  @override
  Future<DateTime?> getLastReadTime(int surahNumber) async {
    final timeString =
        sharedPreferences.getString('$_lastReadTimePrefix$surahNumber');
    return timeString != null ? DateTime.parse(timeString) : null;
  }

  @override
  Future<void> updateLastRead(int surahNumber, int verseNumber) async {
    await sharedPreferences.setInt('$_lastReadPrefix$surahNumber', verseNumber);
    await sharedPreferences.setString(
        '$_lastReadTimePrefix$surahNumber', DateTime.now().toIso8601String());
  }

  @override
  Future<bool> isSurahFavorite(int surahNumber) async {
    final favorites = await getFavoriteSurahs();
    return favorites.contains(surahNumber);
  }

  @override
  Future<bool> isVerseFavorite(int surahNumber, int verseNumber) async {
    final favorites = await getFavoriteVerses();
    return favorites.contains('$surahNumber:$verseNumber');
  }

  @override
  Future<bool> isVerseBookmarked(int surahNumber, int verseNumber) async {
    final bookmarks = await getBookmarkedVerses();
    return bookmarks.contains('$surahNumber:$verseNumber');
  }

  @override
  Future<void> toggleSurahFavorite(int surahNumber) async {
    final favorites = await getFavoriteSurahs();
    if (favorites.contains(surahNumber)) {
      favorites.remove(surahNumber);
    } else {
      favorites.add(surahNumber);
    }
    await sharedPreferences.setStringList(
        _favoriteSurahsKey, favorites.map((e) => e.toString()).toList());
  }

  @override
  Future<void> toggleVerseFavorite(int surahNumber, int verseNumber) async {
    final favorites = await getFavoriteVerses();
    final verseRef = '$surahNumber:$verseNumber';
    if (favorites.contains(verseRef)) {
      favorites.remove(verseRef);
    } else {
      favorites.add(verseRef);
    }
    await sharedPreferences.setStringList(_favoriteVersesKey, favorites);
  }

  @override
  Future<void> toggleVerseBookmark(int surahNumber, int verseNumber) async {
    final bookmarks = await getBookmarkedVerses();
    final verseRef = '$surahNumber:$verseNumber';
    if (bookmarks.contains(verseRef)) {
      bookmarks.remove(verseRef);
    } else {
      bookmarks.add(verseRef);
    }
    await sharedPreferences.setStringList(_bookmarkedVersesKey, bookmarks);
  }

  @override
  Future<List<int>> getFavoriteSurahs() async {
    final favorites = sharedPreferences.getStringList(_favoriteSurahsKey) ?? [];
    return favorites.map((e) => int.parse(e)).toList();
  }

  @override
  Future<List<String>> getFavoriteVerses() async {
    return sharedPreferences.getStringList(_favoriteVersesKey) ?? [];
  }

  @override
  Future<List<String>> getBookmarkedVerses() async {
    return sharedPreferences.getStringList(_bookmarkedVersesKey) ?? [];
  }

  @override
  Future<String?> getVerseNote(int surahNumber, int verseNumber) async {
    return sharedPreferences
        .getString('$_verseNotePrefix${surahNumber}_$verseNumber');
  }

  @override
  Future<void> addVerseNote(
      int surahNumber, int verseNumber, String note) async {
    await sharedPreferences.setString(
        '$_verseNotePrefix${surahNumber}_$verseNumber', note);
  }

  @override
  Future<List<String>> getVerseTags(int surahNumber, int verseNumber) async {
    return sharedPreferences
            .getStringList('$_verseTagsPrefix${surahNumber}_$verseNumber') ??
        [];
  }

  @override
  Future<void> addVerseTag(int surahNumber, int verseNumber, String tag) async {
    final tags = await getVerseTags(surahNumber, verseNumber);
    if (!tags.contains(tag)) {
      tags.add(tag);
      await sharedPreferences.setStringList(
          '$_verseTagsPrefix${surahNumber}_$verseNumber', tags);
    }
  }

  @override
  Future<void> removeVerseTag(
      int surahNumber, int verseNumber, String tag) async {
    final tags = await getVerseTags(surahNumber, verseNumber);
    tags.remove(tag);
    await sharedPreferences.setStringList(
        '$_verseTagsPrefix${surahNumber}_$verseNumber', tags);
  }

  @override
  Future<QuranStats> getReadingStats() async {
    final favoriteSurahs = await getFavoriteSurahs();
    final favoriteVerses = await getFavoriteVerses();
    final bookmarkedVerses = await getBookmarkedVerses();

    int totalSurahsRead = 0;
    int totalVersesRead = 0;
    Map<int, double> surahProgress = {};
    QuranEntity? currentlyReading;
    DateTime? lastSession;

    // Calculate progress for each surah
    for (int i = 1; i <= 114; i++) {
      final lastRead = await getLastReadVerse(i);
      if (lastRead > 0) {
        totalSurahsRead++;
        totalVersesRead += lastRead;

        // Get total verses for this surah (would need quran_library integration)
        final progress =
            lastRead / 286.0; // placeholder, should be actual verse count
        surahProgress[i] = progress;

        final readTime = await getLastReadTime(i);
        if (readTime != null &&
            (lastSession == null || readTime.isAfter(lastSession))) {
          lastSession = readTime;
          // Would set currentlyReading here
        }
      }
    }

    final overallProgress = totalVersesRead / 6236.0; // Total verses in Quran

    return QuranStats(
      totalSurahsRead: totalSurahsRead,
      totalVersesRead: totalVersesRead,
      favoriteSurahsCount: favoriteSurahs.length,
      favoriteVersesCount: favoriteVerses.length,
      bookmarkedVersesCount: bookmarkedVerses.length,
      overallProgress: overallProgress,
      currentlyReading: currentlyReading,
      lastReadingSession: lastSession,
      surahProgress: surahProgress,
    );
  }

  @override
  Future<void> saveCurrentPage(int pageNumber) async {
    await sharedPreferences.setInt(_currentPageKey, pageNumber);
  }

  @override
  Future<int> getCurrentPage() async {
    return sharedPreferences.getInt(_currentPageKey) ?? 1;
  }

  @override
  Future<void> savePageReadingPosition(
      int pageNumber, double scrollPosition) async {
    await sharedPreferences.setDouble(
        '$_pagePositionPrefix$pageNumber', scrollPosition);
  }

  @override
  Future<double> getPageReadingPosition(int pageNumber) async {
    return sharedPreferences.getDouble('$_pagePositionPrefix$pageNumber') ??
        0.0;
  }
}
