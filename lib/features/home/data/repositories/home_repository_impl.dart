import '../../domain/entities/home_feature.dart';
import '../../domain/repositories/home_repository.dart';

/// Implementation of the home repository
class HomeRepositoryImpl implements HomeRepository {
  @override
  List<HomeFeature> getHomeFeatures() {
    return [
      const HomeFeature(
        id: 'sebha',
        titleArabic: 'عداد التسبيح',
        titleEnglish: 'Sebha Counter',
        iconPath: 'assets/icons/sebha.svg',
        route: '/sebha',
        color: 'green',
        description: 'عداد إلكتروني للتسبيح والتهليل',
      ),
      const HomeFeature(
        id: 'azkar',
        titleArabic: 'أذكار الصباح والمساء',
        titleEnglish: 'Morning & Evening Azkar',
        iconPath: 'assets/icons/azkar.svg',
        route: '/azkar',
        color: 'blue',
        description: 'أذكار الصباح والمساء مع العداد',
      ),
      const HomeFeature(
        id: 'quran',
        titleArabic: 'ورد القرآن اليومي',
        titleEnglish: 'Daily Quran Reading',
        iconPath: 'assets/icons/quran.svg',
        route: '/quran',
        color: 'gold',
        description: 'ورد يومي من القرآن الكريم',
      ),
      const HomeFeature(
        id: 'prayer',
        titleArabic: 'أوقات الصلاة والقبلة',
        titleEnglish: 'Prayer Times & Qibla',
        iconPath: 'assets/icons/prayer.svg',
        route: '/prayer',
        color: 'orange',
        description: 'مواقيت الصلاة واتجاه القبلة',
      ),
      const HomeFeature(
        id: 'audio_azkar',
        titleArabic: 'أذكار مسموعة',
        titleEnglish: 'Audio Azkar',
        iconPath: 'assets/icons/audio.svg',
        route: '/audio-azkar',
        color: 'purple',
        description: 'أذكار صوتية للاستماع والتأمل',
      ),
      const HomeFeature(
        id: 'statistics',
        titleArabic: 'إحصائيات',
        titleEnglish: 'Statistics',
        iconPath: 'assets/icons/statistics.svg',
        route: '/statistics',
        color: 'teal',
        description: 'إحصائيات الأنشطة الدينية',
      ),
    ];
  }

  @override
  Map<String, dynamic> getUserPreferences() {
    return {
      'language': 'ar',
      'theme': 'light',
      'notifications': true,
      'location': 'auto',
    };
  }

  @override
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    // Implementation for saving preferences
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  String getGreetingMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      return 'صباح الخير';
    } else if (hour >= 12 && hour < 17) {
      return 'نهار مبارك';
    } else if (hour >= 17 && hour < 21) {
      return 'مساء الخير';
    } else {
      return 'ليلة مباركة';
    }
  }

  @override
  Map<String, int> getUserStats() {
    return {
      'todayAzkar': 5,
      'todaySebha': 99,
      'todayQuran': 2, // pages read
      'streak': 7, // consecutive days
    };
  }
}
