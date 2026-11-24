import 'package:hive_flutter/hive_flutter.dart';

enum WorshipActivity { tasbeeh, adhkar, quran, prayer }

class WorshipLog {
  static bool get isAvailable => Hive.isBoxOpen('statistics');
  static Box get box => Hive.box('statistics');

  static DateTime day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _dateKey(DateTime date) =>
      day(date).toIso8601String().split('T').first;

  static String _key(WorshipActivity activity, DateTime date) =>
      'activity_${activity.name}_${_dateKey(date)}';

  static int count(WorshipActivity activity, DateTime date) {
    if (!isAvailable) return 0;
    return box.get(_key(activity, date), defaultValue: 0) as int;
  }

  static int total(WorshipActivity activity) {
    if (!isAvailable) return 0;
    final legacyKey = switch (activity) {
      WorshipActivity.tasbeeh => 'total_tasbeeh',
      WorshipActivity.adhkar => 'total_azkar',
      WorshipActivity.quran => 'total_quran_pages',
      WorshipActivity.prayer => 'prayers_on_time',
    };
    var total = (box.get(legacyKey, defaultValue: 0) as num).toInt();
    for (final key in box.keys.whereType<String>()) {
      if (key.startsWith('activity_${activity.name}_')) {
        total += (box.get(key) as num).toInt();
      }
    }
    return total;
  }

  static Future<void> record(WorshipActivity activity) async {
    if (!isAvailable) return;
    final today = DateTime.now();
    await box.put(_key(activity, today), count(activity, today) + 1);
  }

  static Future<void> openQuranPage(int page) async {
    if (!isAvailable) return;
    final today = DateTime.now();
    final key = 'opened_quran_${_dateKey(today)}';
    final pages = List<int>.from(box.get(key, defaultValue: <int>[]) as List);
    if (pages.contains(page)) return;
    await box.putAll({
      key: [...pages, page],
      _key(WorshipActivity.quran, today): pages.length + 1,
    });
  }

  static bool prayerCompleted(String prayer, DateTime date) {
    if (!isAvailable) return false;
    return (box.get('completed_prayer_${_dateKey(date)}', defaultValue: <String>[])
            as List)
        .contains(prayer);
  }

  static Future<void> setPrayerCompleted(
    String prayer,
    DateTime date,
    bool completed,
  ) async {
    if (!isAvailable) return;
    final key = 'completed_prayer_${_dateKey(date)}';
    final prayers = List<String>.from(
      box.get(key, defaultValue: <String>[]) as List,
    );
    if (completed && !prayers.contains(prayer)) prayers.add(prayer);
    if (!completed) prayers.remove(prayer);
    await box.putAll({
      key: prayers,
      _key(WorshipActivity.prayer, date): prayers.length,
    });
  }

  /// حساب نقاط اليوم من مختلف الأنشطة التعبدية
  static int dailyScore([DateTime? date]) {
    if (!isAvailable) return 0;
    final target = date ?? DateTime.now();
    final prayers = count(WorshipActivity.prayer, target);
    final adhkar = count(WorshipActivity.adhkar, target);
    final quran = count(WorshipActivity.quran, target);
    final tasbeeh = count(WorshipActivity.tasbeeh, target);
    return (prayers * 25) + (adhkar * 20) + (quran * 10) + (tasbeeh ~/ 5);
  }

  /// حساب إجمالي النقاط لكل الأوقات
  static int totalScore() {
    if (!isAvailable) return 0;
    final prayers = total(WorshipActivity.prayer);
    final adhkar = total(WorshipActivity.adhkar);
    final quran = total(WorshipActivity.quran);
    final tasbeeh = total(WorshipActivity.tasbeeh);
    return (prayers * 25) + (adhkar * 20) + (quran * 10) + (tasbeeh ~/ 5);
  }

  /// السلسلة اليومية الحالية بالأيام
  static int currentStreak() {
    if (!isAvailable) return 1;
    final today = DateTime.now();
    int streak = 0;
    // Check backwards from today or yesterday
    for (int i = 0; i < 30; i++) {
      final target = DateTime(today.year, today.month, today.day - i);
      final countTotal = count(WorshipActivity.prayer, target) +
          count(WorshipActivity.adhkar, target) +
          count(WorshipActivity.quran, target) +
          count(WorshipActivity.tasbeeh, target);
      if (countTotal > 0) {
        streak++;
      } else if (i == 0) {
        // Today has just started or no logs yet, check yesterday before breaking
        continue;
      } else {
        break;
      }
    }
    return streak == 0 ? 1 : streak;
  }

  /// شارة المستخدم بناءً على إجمالي النقاط
  static String userBadgeName(int score, {required bool arabic}) {
    if (score >= 600) {
      return arabic ? 'سابق بالخيرات' : 'Pioneer';
    } else if (score >= 300) {
      return arabic ? 'نور الطمأنينة' : 'Radiant';
    } else if (score >= 100) {
      return arabic ? 'الذاكر المثابر' : 'Devoted';
    } else {
      return arabic ? 'مبتدئ الطمأنينة' : 'Seeker';
    }
  }
}
