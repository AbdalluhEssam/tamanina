import 'dart:ui';

/// ثوابت التطبيق الأساسية
/// Core App Constants
class AppConstants {
  // معلومات التطبيق
  static const String appName = 'طمأنينة';
  static const String appNameEnglish = 'Tamanina';
  static const String appVersion = '1.0.0';
  static const String appSlogan = 'رفيقك في رحلة الإيمان';
  static const String appSloganEnglish =
      'Your companion in the journey of faith';

  // اللغات المدعومة
  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];
  static const String localeKey = 'app_locale';
  static const String themeKey = 'app_theme';

  // قواعد البيانات
  static const String dbName = 'tamanina.db';
  static const int dbVersion = 1;

  // مفاتيح التخزين المحلي
  static const String prefKeyFirstRun = 'first_run';
  static const String prefKeyLanguage = 'language';
  static const String prefKeyTheme = 'theme_mode';
  static const String prefKeyNotifications = 'notifications_enabled';
  static const String prefKeyLocation = 'user_location';
  static const String prefKeyPrayerSettings = 'prayer_settings';
  static const String prefKeyOnboardingCompleted = 'onboarding_completed';

  // URLs وروابط
  static const String privacyPolicyUrl = 'https://tamanina.app/privacy';
  static const String termsOfServiceUrl = 'https://tamanina.app/terms';
  static const String supportEmailUrl = 'mailto:support@tamanina.app';
  static const String appStoreUrl = 'https://apps.apple.com/app/tamanina';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.tamanina.app';

  // القيم الافتراضية
  static const int defaultNotificationMinutes = 15;
  static const int defaultSebhaCount = 33;
  static const double defaultTextSize = 16.0;
  static const String defaultCalculationMethod = 'UmmAlQura';

  // حدود وقيود
  static const int maxRecentAzkar = 10;
  static const int maxBookmarkedVerses = 100;
  static const int maxCustomNotes = 500; // حد الأحرف للملاحظات

  // فترات زمنية
  static const int splashDurationMs = 5000; // زيادة المدة إلى 5 ثوان
  static const int animationDurationMs = 300;
  static const int notificationIntervalMinutes = 60;

  // أسماء الملفات والمجلدات
  static const String azkarAssetsFolder = 'assets/data/';
  static const String quranAssetsFolder = 'assets/quran/';
  static const String audioAssetsFolder = 'assets/audio/';
  static const String imagesAssetsFolder = 'assets/images/';

  // Keys للإحصائيات والتحليلات
  static const String eventPrayerCompleted = 'prayer_completed';
  static const String eventAzkarRead = 'azkar_read';
  static const String eventQuranRead = 'quran_read';
  static const String eventSebhaUsed = 'sebha_used';
}

/// أسماء المسارات للتنقل
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String prayer = '/prayer';
  static const String azkar = '/azkar';
  static const String quran = '/quran';
  static const String sebha = '/sebha';
  static const String qibla = '/qibla';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
}

/// مسارات الملفات والأصول
class AppAssets {
  // الصور
  static const String logo = 'assets/images/logo.png';
  static const String kaaba = 'assets/images/kaaba.png';
  static const String mosque = 'assets/images/mosque.png';

  // الرسوم المتحركة
  static const String prayerAnimation = 'assets/lottie/prayer.json';
  static const String azkarAnimation = 'assets/lottie/azkar.json';
  static const String quranAnimation = 'assets/lottie/quran.json';
  static const String qiblaAnimation = 'assets/lottie/qibla.json';
  static const String loadingAnimation = 'assets/lottie/loading.json';

  // البيانات
  static const String morningAzkar = 'assets/data/morning_azkar.json';
  static const String eveningAzkar = 'assets/data/evening_azkar.json';
  static const String afterPrayerAzkar = 'assets/data/after_prayer_azkar.json';
  static const String sleepAzkar = 'assets/data/sleep_azkar.json';

  // الأصوات
  static const String adhanMakkah = 'assets/audio/adhan_makkah.mp3';
  static const String adhanMadinah = 'assets/audio/adhan_madinah.mp3';
  static const String clickSound = 'assets/audio/click.wav';
  static const String completionSound = 'assets/audio/completion.wav';

  // الأيقونات
  static const String prayerIcon = 'assets/icons/prayer.svg';
  static const String azkarIcon = 'assets/icons/azkar.svg';
  static const String quranIcon = 'assets/icons/quran.svg';
  static const String sebhaIcon = 'assets/icons/sebha.svg';
  static const String qiblaIcon = 'assets/icons/qibla.svg';
  static const String statisticsIcon = 'assets/icons/statistics.svg';
}

/// إعدادات التصميم
class AppDimensions {
  // الحواف والمسافات
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // الأحجام
  static const double iconSizeXS = 16.0;
  static const double iconSizeSM = 20.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 32.0;
  static const double iconSizeXL = 48.0;

  // نصف قطر الحواف
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;

  // ارتفاعات الظلال
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;
}

/// إعدادات الرسوم المتحركة
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 1000);
}
