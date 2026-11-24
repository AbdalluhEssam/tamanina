import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'mushaf_library.dart';

/// مدير بسيط لحفظ واستعادة موضع القراءة
class ReadingPositionManager {
  static const String _lastPageKey = 'last_mushaf_page_v2';
  static const String _lastScrollPositionKey = 'last_scroll_position_v2';
  static const String _bookmarksKey = 'mushaf_bookmarks_v2';
  static const String _readingHistoryKey = 'reading_history_v2';

  static Future<SharedPreferences>? _initialization;

  static Future<SharedPreferences> _preferences() =>
      _initialization ??= _migrateLegacyPages();

  static Future<SharedPreferences> _migrateLegacyPages() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('mushaf_pages_migrated') == true) return prefs;

    final previous = prefs.getInt('last_mushaf_page');
    if (previous != null) {
      await prefs.setInt(_lastPageKey, MushafLibrary.migratePage(previous));
    }
    for (final (oldKey, newKey) in [
      ('mushaf_bookmarks', _bookmarksKey),
      ('reading_history', _readingHistoryKey),
    ]) {
      final legacyJson = prefs.getString(oldKey);
      if (legacyJson == null) continue;
      final Object? decoded;
      try {
        decoded = jsonDecode(legacyJson);
      } on FormatException {
        continue;
      }
      if (decoded is! List) continue;
      final migrated = <int, Map<String, dynamic>>{};
      for (final entry in decoded.whereType<Map<String, dynamic>>()) {
        if (entry['page'] case final int page) {
          final number = MushafLibrary.migratePage(page);
          migrated[number] = {...entry, 'page': number};
        }
      }
      await prefs.setString(newKey, jsonEncode(migrated.values.toList()));
    }
    await prefs.setBool('mushaf_pages_migrated', true);
    return prefs;
  }

  /// حفظ الصفحة الحالية
  static Future<void> saveCurrentPage(int pageNumber) async {
    try {
      final prefs = await _preferences();
      await prefs.setInt(_lastPageKey, pageNumber);

      // إضافة إلى التاريخ
      await _addToHistory(pageNumber);

      print('✅ تم حفظ الصفحة: $pageNumber');
    } catch (e) {
      print('❌ خطأ في حفظ الصفحة: $e');
    }
  }

  /// استعادة الصفحة المحفوظة
  static Future<int> getCurrentPage() async {
    try {
      final prefs = await _preferences();
      int savedPage = prefs.getInt(_lastPageKey) ?? 1;
      print('✅ تم استعادة الصفحة: $savedPage');
      return savedPage;
    } catch (e) {
      print('❌ خطأ في استعادة الصفحة: $e');
      return 1;
    }
  }

  /// حفظ موضع التمرير في الصفحة
  static Future<void> saveScrollPosition(
    int pageNumber,
    double scrollPosition,
  ) async {
    try {
      final prefs = await _preferences();
      await prefs.setDouble(
        '${_lastScrollPositionKey}_$pageNumber',
        scrollPosition,
      );
    } catch (e) {
      print('❌ خطأ في حفظ موضع التمرير: $e');
    }
  }

  /// استعادة موضع التمرير للصفحة
  static Future<double> getScrollPosition(int pageNumber) async {
    try {
      final prefs = await _preferences();
      return prefs.getDouble('${_lastScrollPositionKey}_$pageNumber') ?? 0.0;
    } catch (e) {
      print('❌ خطأ في استعادة موضع التمرير: $e');
      return 0.0;
    }
  }

  /// إضافة علامة مرجعية
  static Future<void> addBookmark(int pageNumber, String title) async {
    try {
      final prefs = await _preferences();
      String? bookmarksJson = prefs.getString(_bookmarksKey);

      List<Map<String, dynamic>> bookmarks = [];
      if (bookmarksJson != null) {
        List<dynamic> decoded = jsonDecode(bookmarksJson);
        bookmarks = decoded.cast<Map<String, dynamic>>();
      }

      // التحقق من عدم وجود العلامة مسبقاً
      bool exists = bookmarks.any((bookmark) => bookmark['page'] == pageNumber);
      if (!exists) {
        bookmarks.add({
          'page': pageNumber,
          'title': title,
          'timestamp': DateTime.now().toIso8601String(),
        });

        await prefs.setString(_bookmarksKey, jsonEncode(bookmarks));
        print('✅ تم إضافة علامة مرجعية للصفحة: $pageNumber');
      }
    } catch (e) {
      print('❌ خطأ في إضافة العلامة المرجعية: $e');
    }
  }

  /// الحصول على العلامات المرجعية
  static Future<List<BookmarkModel>> getBookmarks() async {
    try {
      final prefs = await _preferences();
      String? bookmarksJson = prefs.getString(_bookmarksKey);

      if (bookmarksJson == null) return [];

      List<dynamic> decoded = jsonDecode(bookmarksJson);
      List<Map<String, dynamic>> bookmarks = decoded
          .cast<Map<String, dynamic>>();

      return bookmarks
          .map((bookmark) => BookmarkModel.fromJson(bookmark))
          .toList();
    } catch (e) {
      print('❌ خطأ في استعادة العلامات المرجعية: $e');
      return [];
    }
  }

  /// حذف علامة مرجعية
  static Future<void> removeBookmark(int pageNumber) async {
    try {
      final prefs = await _preferences();
      String? bookmarksJson = prefs.getString(_bookmarksKey);

      if (bookmarksJson == null) return;

      List<dynamic> decoded = jsonDecode(bookmarksJson);
      List<Map<String, dynamic>> bookmarks = decoded
          .cast<Map<String, dynamic>>();

      bookmarks.removeWhere((bookmark) => bookmark['page'] == pageNumber);

      await prefs.setString(_bookmarksKey, jsonEncode(bookmarks));
      print('✅ تم حذف العلامة المرجعية للصفحة: $pageNumber');
    } catch (e) {
      print('❌ خطأ في حذف العلامة المرجعية: $e');
    }
  }

  /// إضافة إلى تاريخ القراءة
  static Future<void> _addToHistory(int pageNumber) async {
    try {
      final prefs = await _preferences();
      String? historyJson = prefs.getString(_readingHistoryKey);

      List<Map<String, dynamic>> history = [];
      if (historyJson != null) {
        List<dynamic> decoded = jsonDecode(historyJson);
        history = decoded.cast<Map<String, dynamic>>();
      }

      // إضافة أو تحديث الإدخال
      int existingIndex = history.indexWhere(
        (entry) => entry['page'] == pageNumber,
      );

      Map<String, dynamic> newEntry = {
        'page': pageNumber,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (existingIndex >= 0) {
        history[existingIndex] = newEntry;
      } else {
        history.add(newEntry);
      }

      // الاحتفاظ بآخر 50 إدخال فقط
      if (history.length > 50) {
        history.sort(
          (a, b) => DateTime.parse(
            b['timestamp'],
          ).compareTo(DateTime.parse(a['timestamp'])),
        );
        history = history.take(50).toList();
      }

      await prefs.setString(_readingHistoryKey, jsonEncode(history));
    } catch (e) {
      print('❌ خطأ في إضافة التاريخ: $e');
    }
  }

  /// الحصول على تاريخ القراءة
  static Future<List<ReadingHistoryModel>> getReadingHistory() async {
    try {
      final prefs = await _preferences();
      String? historyJson = prefs.getString(_readingHistoryKey);

      if (historyJson == null) return [];

      List<dynamic> decoded = jsonDecode(historyJson);
      List<Map<String, dynamic>> history = decoded.cast<Map<String, dynamic>>();

      List<ReadingHistoryModel> result = history
          .map((entry) => ReadingHistoryModel.fromJson(entry))
          .toList();

      // ترتيب حسب الأحدث
      result.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return result;
    } catch (e) {
      print('❌ خطأ في استعادة التاريخ: $e');
      return [];
    }
  }

  /// مسح جميع البيانات
  static Future<void> clearAll() async {
    try {
      final prefs = await _preferences();
      await prefs.remove(_lastPageKey);
      await prefs.remove(_bookmarksKey);
      await prefs.remove(_readingHistoryKey);
      print('✅ تم مسح جميع بيانات القراءة');
    } catch (e) {
      print('❌ خطأ في مسح البيانات: $e');
    }
  }
}

/// نموذج العلامة المرجعية
class BookmarkModel {
  final int page;
  final String title;
  final DateTime timestamp;

  BookmarkModel({
    required this.page,
    required this.title,
    required this.timestamp,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      page: json['page'] as int,
      title: json['title'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// نموذج تاريخ القراءة
class ReadingHistoryModel {
  final int page;
  final DateTime timestamp;

  ReadingHistoryModel({required this.page, required this.timestamp});

  factory ReadingHistoryModel.fromJson(Map<String, dynamic> json) {
    return ReadingHistoryModel(
      page: json['page'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'page': page, 'timestamp': timestamp.toIso8601String()};
  }
}
