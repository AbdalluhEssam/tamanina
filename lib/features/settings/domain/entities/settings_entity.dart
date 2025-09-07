import 'package:equatable/equatable.dart';

/// نموذج إعدادات التطبيق
/// App Settings Data Model
class SettingsEntity extends Equatable {
  final AppLanguage language; // اللغة
  final AppThemeMode themeMode; // وضع السمة
  final NotificationSettings notifications; // إعدادات الإشعارات
  final PrayerSettings prayerSettings; // إعدادات الصلاة
  final AzkarSettings azkarSettings; // إعدادات الأذكار
  final QuranSettings quranSettings; // إعدادات القرآن
  final LocationSettings locationSettings; // إعدادات الموقع
  final DisplaySettings displaySettings; // إعدادات العرض
  final AudioSettings audioSettings; // إعدادات الصوت
  final BackupSettings backupSettings; // إعدادات النسخ الاحتياطي
  final PrivacySettings privacySettings; // إعدادات الخصوصية
  final AccessibilitySettings accessibilitySettings; // إعدادات إمكانية الوصول

  const SettingsEntity({
    this.language = AppLanguage.arabic,
    this.themeMode = AppThemeMode.system,
    this.notifications = const NotificationSettings(),
    this.prayerSettings = const PrayerSettings(),
    this.azkarSettings = const AzkarSettings(),
    this.quranSettings = const QuranSettings(),
    this.locationSettings = const LocationSettings(),
    this.displaySettings = const DisplaySettings(),
    this.audioSettings = const AudioSettings(),
    this.backupSettings = const BackupSettings(),
    this.privacySettings = const PrivacySettings(),
    this.accessibilitySettings = const AccessibilitySettings(),
  });

  SettingsEntity copyWith({
    AppLanguage? language,
    AppThemeMode? themeMode,
    NotificationSettings? notifications,
    PrayerSettings? prayerSettings,
    AzkarSettings? azkarSettings,
    QuranSettings? quranSettings,
    LocationSettings? locationSettings,
    DisplaySettings? displaySettings,
    AudioSettings? audioSettings,
    BackupSettings? backupSettings,
    PrivacySettings? privacySettings,
    AccessibilitySettings? accessibilitySettings,
  }) {
    return SettingsEntity(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      notifications: notifications ?? this.notifications,
      prayerSettings: prayerSettings ?? this.prayerSettings,
      azkarSettings: azkarSettings ?? this.azkarSettings,
      quranSettings: quranSettings ?? this.quranSettings,
      locationSettings: locationSettings ?? this.locationSettings,
      displaySettings: displaySettings ?? this.displaySettings,
      audioSettings: audioSettings ?? this.audioSettings,
      backupSettings: backupSettings ?? this.backupSettings,
      privacySettings: privacySettings ?? this.privacySettings,
      accessibilitySettings:
          accessibilitySettings ?? this.accessibilitySettings,
    );
  }

  @override
  List<Object> get props => [
        language,
        themeMode,
        notifications,
        prayerSettings,
        azkarSettings,
        quranSettings,
        locationSettings,
        displaySettings,
        audioSettings,
        backupSettings,
        privacySettings,
        accessibilitySettings,
      ];
}

/// لغات التطبيق
enum AppLanguage {
  arabic('العربية', 'ar', 'Arabic'),
  english('English', 'en', 'English');

  const AppLanguage(this.displayName, this.code, this.englishName);

  final String displayName;
  final String code;
  final String englishName;
}

/// أوضاع السمة
enum AppThemeMode {
  light('فاتح', 'Light'),
  dark('داكن', 'Dark'),
  system('حسب النظام', 'System Default');

  const AppThemeMode(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// إعدادات الإشعارات
class NotificationSettings extends Equatable {
  final bool enableNotifications; // تفعيل الإشعارات
  final bool prayerNotifications; // إشعارات الصلاة
  final bool azkarReminders; // تذكير الأذكار
  final bool quranReminders; // تذكير القرآن
  final bool achievementNotifications; // إشعارات الإنجازات
  final NotificationSound soundType; // نوع الصوت
  final bool vibration; // الاهتزاز
  final int quietHoursStart; // بداية ساعات الهدوء (24-hour format)
  final int quietHoursEnd; // نهاية ساعات الهدوء
  final bool quietHoursEnabled; // تفعيل ساعات الهدوء

  const NotificationSettings({
    this.enableNotifications = true,
    this.prayerNotifications = true,
    this.azkarReminders = true,
    this.quranReminders = false,
    this.achievementNotifications = true,
    this.soundType = NotificationSound.default_sound,
    this.vibration = true,
    this.quietHoursStart = 22,
    this.quietHoursEnd = 7,
    this.quietHoursEnabled = false,
  });

  NotificationSettings copyWith({
    bool? enableNotifications,
    bool? prayerNotifications,
    bool? azkarReminders,
    bool? quranReminders,
    bool? achievementNotifications,
    NotificationSound? soundType,
    bool? vibration,
    int? quietHoursStart,
    int? quietHoursEnd,
    bool? quietHoursEnabled,
  }) {
    return NotificationSettings(
      enableNotifications: enableNotifications ?? this.enableNotifications,
      prayerNotifications: prayerNotifications ?? this.prayerNotifications,
      azkarReminders: azkarReminders ?? this.azkarReminders,
      quranReminders: quranReminders ?? this.quranReminders,
      achievementNotifications:
          achievementNotifications ?? this.achievementNotifications,
      soundType: soundType ?? this.soundType,
      vibration: vibration ?? this.vibration,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    );
  }

  @override
  List<Object> get props => [
        enableNotifications,
        prayerNotifications,
        azkarReminders,
        quranReminders,
        achievementNotifications,
        soundType,
        vibration,
        quietHoursStart,
        quietHoursEnd,
        quietHoursEnabled,
      ];
}

/// أصوات الإشعارات
enum NotificationSound {
  default_sound('الافتراضي', 'Default'),
  adhan('الأذان', 'Adhan'),
  gentle('هادئ', 'Gentle'),
  bell('جرس', 'Bell'),
  silent('صامت', 'Silent');

  const NotificationSound(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// إعدادات الصلاة
class PrayerSettings extends Equatable {
  final CalculationMethod calculationMethod; // طريقة الحساب
  final MadhabSchool madhab; // المذهب الفقهي
  final int fajrAngle; // زاوية الفجر
  final int ishaAngle; // زاوية العشاء
  final bool enableAdhan; // تفعيل الأذان
  final AdhanSound adhanSound; // صوت الأذان
  final Map<String, int> prayerAdjustments; // تعديلات أوقات الصلاة
  final bool enable24HourFormat; // استخدام نظام 24 ساعة
  final bool showSunrise; // عرض وقت الشروق
  final bool autoLocationUpdate; // تحديث الموقع تلقائياً

  const PrayerSettings({
    this.calculationMethod = CalculationMethod.ummAlQura,
    this.madhab = MadhabSchool.shafi,
    this.fajrAngle = 18,
    this.ishaAngle = 17,
    this.enableAdhan = true,
    this.adhanSound = AdhanSound.makkah,
    this.prayerAdjustments = const {},
    this.enable24HourFormat = false,
    this.showSunrise = true,
    this.autoLocationUpdate = true,
  });

  PrayerSettings copyWith({
    CalculationMethod? calculationMethod,
    MadhabSchool? madhab,
    int? fajrAngle,
    int? ishaAngle,
    bool? enableAdhan,
    AdhanSound? adhanSound,
    Map<String, int>? prayerAdjustments,
    bool? enable24HourFormat,
    bool? showSunrise,
    bool? autoLocationUpdate,
  }) {
    return PrayerSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      fajrAngle: fajrAngle ?? this.fajrAngle,
      ishaAngle: ishaAngle ?? this.ishaAngle,
      enableAdhan: enableAdhan ?? this.enableAdhan,
      adhanSound: adhanSound ?? this.adhanSound,
      prayerAdjustments: prayerAdjustments ?? this.prayerAdjustments,
      enable24HourFormat: enable24HourFormat ?? this.enable24HourFormat,
      showSunrise: showSunrise ?? this.showSunrise,
      autoLocationUpdate: autoLocationUpdate ?? this.autoLocationUpdate,
    );
  }

  @override
  List<Object> get props => [
        calculationMethod,
        madhab,
        fajrAngle,
        ishaAngle,
        enableAdhan,
        adhanSound,
        prayerAdjustments,
        enable24HourFormat,
        showSunrise,
        autoLocationUpdate,
      ];
}

/// طرق حساب أوقات الصلاة
enum CalculationMethod {
  ummAlQura('أم القرى', 'Umm al-Qura University, Makkah'),
  egyptian('المساحة المصرية', 'Egyptian General Authority of Survey'),
  karachi('جامعة كراتشي', 'University of Karachi'),
  northAmerica('أمريكا الشمالية', 'Islamic Society of North America'),
  muslimWorldLeague('رابطة العالم الإسلامي', 'Muslim World League'),
  dubai('دبي', 'Dubai (unofficial)'),
  qatar('قطر', 'Qatar Calendar House'),
  kuwait('الكويت', 'Kuwait'),
  singapore('سنغافورة', 'Singapore');

  const CalculationMethod(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// المذاهب الفقهية
enum MadhabSchool {
  shafi('الشافعي', 'Shafi'),
  hanafi('الحنفي', 'Hanafi'),
  maliki('المالكي', 'Maliki'),
  hanbali('الحنبلي', 'Hanbali');

  const MadhabSchool(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// أصوات الأذان
enum AdhanSound {
  makkah('مكة المكرمة', 'Makkah'),
  madinah('المدينة المنورة', 'Madinah'),
  egypt('مصر', 'Egypt'),
  turkey('تركيا', 'Turkey'),
  custom('مخصص', 'Custom');

  const AdhanSound(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// إعدادات الأذكار
class AzkarSettings extends Equatable {
  final bool autoAdvance; // الانتقال التلقائي للذكر التالي
  final bool showTransliteration; // عرض النطق بالحروف الإنجليزية
  final bool showTranslation; // عرض الترجمة
  final bool enableAudio; // تفعيل الصوت
  final double textSize; // حجم النص
  final String fontFamily; // عائلة الخط
  final bool enableCounter; // تفعيل العداد
  final bool vibrateOnComplete; // الاهتزاز عند الانتهاء
  final AzkarDisplayMode displayMode; // وضع العرض

  const AzkarSettings({
    this.autoAdvance = false,
    this.showTransliteration = true,
    this.showTranslation = true,
    this.enableAudio = true,
    this.textSize = 16.0,
    this.fontFamily = 'NotoSansArabic',
    this.enableCounter = true,
    this.vibrateOnComplete = true,
    this.displayMode = AzkarDisplayMode.card,
  });

  AzkarSettings copyWith({
    bool? autoAdvance,
    bool? showTransliteration,
    bool? showTranslation,
    bool? enableAudio,
    double? textSize,
    String? fontFamily,
    bool? enableCounter,
    bool? vibrateOnComplete,
    AzkarDisplayMode? displayMode,
  }) {
    return AzkarSettings(
      autoAdvance: autoAdvance ?? this.autoAdvance,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showTranslation: showTranslation ?? this.showTranslation,
      enableAudio: enableAudio ?? this.enableAudio,
      textSize: textSize ?? this.textSize,
      fontFamily: fontFamily ?? this.fontFamily,
      enableCounter: enableCounter ?? this.enableCounter,
      vibrateOnComplete: vibrateOnComplete ?? this.vibrateOnComplete,
      displayMode: displayMode ?? this.displayMode,
    );
  }

  @override
  List<Object> get props => [
        autoAdvance,
        showTransliteration,
        showTranslation,
        enableAudio,
        textSize,
        fontFamily,
        enableCounter,
        vibrateOnComplete,
        displayMode,
      ];
}

/// أوضاع عرض الأذكار
enum AzkarDisplayMode {
  card('بطاقات', 'Card View'),
  list('قائمة', 'List View'),
  fullscreen('ملء الشاشة', 'Full Screen');

  const AzkarDisplayMode(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// إعدادات القرآن
class QuranSettings extends Equatable {
  final bool showTranslation; // عرض الترجمة
  final bool showTransliteration; // عرض النطق
  final String translationLanguage; // لغة الترجمة
  final String reciterName; // اسم القارئ
  final double textSize; // حجم النص
  final String arabicFont; // الخط العربي
  final bool highlightVerse; // تمييز الآية الحالية
  final bool autoScroll; // التمرير التلقائي
  final PlayMode playMode; // وضع التشغيل
  final bool repeatMode; // وضع التكرار
  final double playbackSpeed; // سرعة التشغيل

  const QuranSettings({
    this.showTranslation = true,
    this.showTransliteration = false,
    this.translationLanguage = 'ar',
    this.reciterName = 'mishary',
    this.textSize = 18.0,
    this.arabicFont = 'Uthmanic',
    this.highlightVerse = true,
    this.autoScroll = true,
    this.playMode = PlayMode.verse,
    this.repeatMode = false,
    this.playbackSpeed = 1.0,
  });

  QuranSettings copyWith({
    bool? showTranslation,
    bool? showTransliteration,
    String? translationLanguage,
    String? reciterName,
    double? textSize,
    String? arabicFont,
    bool? highlightVerse,
    bool? autoScroll,
    PlayMode? playMode,
    bool? repeatMode,
    double? playbackSpeed,
  }) {
    return QuranSettings(
      showTranslation: showTranslation ?? this.showTranslation,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      translationLanguage: translationLanguage ?? this.translationLanguage,
      reciterName: reciterName ?? this.reciterName,
      textSize: textSize ?? this.textSize,
      arabicFont: arabicFont ?? this.arabicFont,
      highlightVerse: highlightVerse ?? this.highlightVerse,
      autoScroll: autoScroll ?? this.autoScroll,
      playMode: playMode ?? this.playMode,
      repeatMode: repeatMode ?? this.repeatMode,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }

  @override
  List<Object> get props => [
        showTranslation,
        showTransliteration,
        translationLanguage,
        reciterName,
        textSize,
        arabicFont,
        highlightVerse,
        autoScroll,
        playMode,
        repeatMode,
        playbackSpeed,
      ];
}

/// أوضاع تشغيل القرآن
enum PlayMode {
  verse('آية بآية', 'Verse by Verse'),
  page('صفحة بصفحة', 'Page by Page'),
  surah('سورة كاملة', 'Complete Surah');

  const PlayMode(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// إعدادات الموقع الجغرافي
class LocationSettings extends Equatable {
  final bool enableLocation; // تفعيل خدمات الموقع
  final bool autoDetectLocation; // تحديد الموقع تلقائياً
  final String manualCity; // المدينة اليدوية
  final String manualCountry; // البلد اليدوي
  final double manualLatitude; // خط العرض اليدوي
  final double manualLongitude; // خط الطول اليدوي
  final bool highAccuracy; // دقة عالية
  final int locationUpdateInterval; // فترة تحديث الموقع (دقائق)

  const LocationSettings({
    this.enableLocation = true,
    this.autoDetectLocation = true,
    this.manualCity = '',
    this.manualCountry = '',
    this.manualLatitude = 0.0,
    this.manualLongitude = 0.0,
    this.highAccuracy = false,
    this.locationUpdateInterval = 60,
  });

  LocationSettings copyWith({
    bool? enableLocation,
    bool? autoDetectLocation,
    String? manualCity,
    String? manualCountry,
    double? manualLatitude,
    double? manualLongitude,
    bool? highAccuracy,
    int? locationUpdateInterval,
  }) {
    return LocationSettings(
      enableLocation: enableLocation ?? this.enableLocation,
      autoDetectLocation: autoDetectLocation ?? this.autoDetectLocation,
      manualCity: manualCity ?? this.manualCity,
      manualCountry: manualCountry ?? this.manualCountry,
      manualLatitude: manualLatitude ?? this.manualLatitude,
      manualLongitude: manualLongitude ?? this.manualLongitude,
      highAccuracy: highAccuracy ?? this.highAccuracy,
      locationUpdateInterval:
          locationUpdateInterval ?? this.locationUpdateInterval,
    );
  }

  @override
  List<Object> get props => [
        enableLocation,
        autoDetectLocation,
        manualCity,
        manualCountry,
        manualLatitude,
        manualLongitude,
        highAccuracy,
        locationUpdateInterval,
      ];
}

/// إعدادات العرض
class DisplaySettings extends Equatable {
  final bool keepScreenOn; // إبقاء الشاشة مضيئة
  final double brightness; // سطوع الشاشة
  final ScreenOrientation orientation; // اتجاه الشاشة
  final bool showSecondsInClock; // عرض الثواني في الساعة
  final ClockFormat clockFormat; // تنسيق الساعة
  final bool enableAnimations; // تفعيل الرسوم المتحركة
  final AnimationSpeed animationSpeed; // سرعة الرسوم المتحركة

  const DisplaySettings({
    this.keepScreenOn = false,
    this.brightness = 0.8,
    this.orientation = ScreenOrientation.auto,
    this.showSecondsInClock = false,
    this.clockFormat = ClockFormat.h12,
    this.enableAnimations = true,
    this.animationSpeed = AnimationSpeed.normal,
  });

  DisplaySettings copyWith({
    bool? keepScreenOn,
    double? brightness,
    ScreenOrientation? orientation,
    bool? showSecondsInClock,
    ClockFormat? clockFormat,
    bool? enableAnimations,
    AnimationSpeed? animationSpeed,
  }) {
    return DisplaySettings(
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      brightness: brightness ?? this.brightness,
      orientation: orientation ?? this.orientation,
      showSecondsInClock: showSecondsInClock ?? this.showSecondsInClock,
      clockFormat: clockFormat ?? this.clockFormat,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      animationSpeed: animationSpeed ?? this.animationSpeed,
    );
  }

  @override
  List<Object> get props => [
        keepScreenOn,
        brightness,
        orientation,
        showSecondsInClock,
        clockFormat,
        enableAnimations,
        animationSpeed,
      ];
}

/// اتجاهات الشاشة
enum ScreenOrientation {
  auto('تلقائي', 'Auto'),
  portrait('عمودي', 'Portrait'),
  landscape('أفقي', 'Landscape');

  const ScreenOrientation(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// تنسيقات الساعة
enum ClockFormat {
  h12('12 ساعة', '12 Hour'),
  h24('24 ساعة', '24 Hour');

  const ClockFormat(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// سرعات الرسوم المتحركة
enum AnimationSpeed {
  slow('بطيء', 'Slow'),
  normal('عادي', 'Normal'),
  fast('سريع', 'Fast');

  const AnimationSpeed(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// إعدادات الصوت
class AudioSettings extends Equatable {
  final double masterVolume; // مستوى الصوت الرئيسي
  final double adhanVolume; // مستوى صوت الأذان
  final double quranVolume; // مستوى صوت القرآن
  final double azkarVolume; // مستوى صوت الأذكار
  final bool enableSoundEffects; // تفعيل المؤثرات الصوتية
  final bool ducksOtherAudio; // تخفيض الصوتيات الأخرى

  const AudioSettings({
    this.masterVolume = 0.8,
    this.adhanVolume = 1.0,
    this.quranVolume = 0.9,
    this.azkarVolume = 0.7,
    this.enableSoundEffects = true,
    this.ducksOtherAudio = true,
  });

  AudioSettings copyWith({
    double? masterVolume,
    double? adhanVolume,
    double? quranVolume,
    double? azkarVolume,
    bool? enableSoundEffects,
    bool? ducksOtherAudio,
  }) {
    return AudioSettings(
      masterVolume: masterVolume ?? this.masterVolume,
      adhanVolume: adhanVolume ?? this.adhanVolume,
      quranVolume: quranVolume ?? this.quranVolume,
      azkarVolume: azkarVolume ?? this.azkarVolume,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      ducksOtherAudio: ducksOtherAudio ?? this.ducksOtherAudio,
    );
  }

  @override
  List<Object> get props => [
        masterVolume,
        adhanVolume,
        quranVolume,
        azkarVolume,
        enableSoundEffects,
        ducksOtherAudio,
      ];
}

/// إعدادات النسخ الاحتياطي
class BackupSettings extends Equatable {
  final bool enableAutoBackup; // تفعيل النسخ الاحتياطي التلقائي
  final BackupFrequency backupFrequency; // تكرار النسخ الاحتياطي
  final bool includeAzkarProgress; // تضمين تقدم الأذكار
  final bool includeQuranProgress; // تضمين تقدم القرآن
  final bool includePrayerHistory; // تضمين سجل الصلوات
  final bool includeSettings; // تضمين الإعدادات
  final DateTime? lastBackupDate; // تاريخ آخر نسخة احتياطية

  const BackupSettings({
    this.enableAutoBackup = false,
    this.backupFrequency = BackupFrequency.weekly,
    this.includeAzkarProgress = true,
    this.includeQuranProgress = true,
    this.includePrayerHistory = true,
    this.includeSettings = true,
    this.lastBackupDate,
  });

  BackupSettings copyWith({
    bool? enableAutoBackup,
    BackupFrequency? backupFrequency,
    bool? includeAzkarProgress,
    bool? includeQuranProgress,
    bool? includePrayerHistory,
    bool? includeSettings,
    DateTime? lastBackupDate,
  }) {
    return BackupSettings(
      enableAutoBackup: enableAutoBackup ?? this.enableAutoBackup,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      includeAzkarProgress: includeAzkarProgress ?? this.includeAzkarProgress,
      includeQuranProgress: includeQuranProgress ?? this.includeQuranProgress,
      includePrayerHistory: includePrayerHistory ?? this.includePrayerHistory,
      includeSettings: includeSettings ?? this.includeSettings,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
    );
  }

  @override
  List<Object?> get props => [
        enableAutoBackup,
        backupFrequency,
        includeAzkarProgress,
        includeQuranProgress,
        includePrayerHistory,
        includeSettings,
        lastBackupDate,
      ];
}

/// تكرارات النسخ الاحتياطي
enum BackupFrequency {
  daily('يومياً', 'Daily'),
  weekly('أسبوعياً', 'Weekly'),
  monthly('شهرياً', 'Monthly');

  const BackupFrequency(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// إعدادات الخصوصية
class PrivacySettings extends Equatable {
  final bool shareUsageData; // مشاركة بيانات الاستخدام
  final bool enableAnalytics; // تفعيل التحليلات
  final bool shareLocationData; // مشاركة بيانات الموقع
  final bool enableCrashReports; // تفعيل تقارير الأعطال
  final bool personalizedAds; // الإعلانات المخصصة
  final DataRetentionPeriod dataRetention; // فترة الاحتفاظ بالبيانات

  const PrivacySettings({
    this.shareUsageData = false,
    this.enableAnalytics = false,
    this.shareLocationData = false,
    this.enableCrashReports = true,
    this.personalizedAds = false,
    this.dataRetention = DataRetentionPeriod.oneYear,
  });

  PrivacySettings copyWith({
    bool? shareUsageData,
    bool? enableAnalytics,
    bool? shareLocationData,
    bool? enableCrashReports,
    bool? personalizedAds,
    DataRetentionPeriod? dataRetention,
  }) {
    return PrivacySettings(
      shareUsageData: shareUsageData ?? this.shareUsageData,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      shareLocationData: shareLocationData ?? this.shareLocationData,
      enableCrashReports: enableCrashReports ?? this.enableCrashReports,
      personalizedAds: personalizedAds ?? this.personalizedAds,
      dataRetention: dataRetention ?? this.dataRetention,
    );
  }

  @override
  List<Object> get props => [
        shareUsageData,
        enableAnalytics,
        shareLocationData,
        enableCrashReports,
        personalizedAds,
        dataRetention,
      ];
}

/// فترات الاحتفاظ بالبيانات
enum DataRetentionPeriod {
  oneMonth('شهر واحد', 'One Month'),
  threeMonths('3 أشهر', '3 Months'),
  sixMonths('6 أشهر', '6 Months'),
  oneYear('سنة واحدة', 'One Year'),
  forever('دائماً', 'Forever');

  const DataRetentionPeriod(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// إعدادات إمكانية الوصول
class AccessibilitySettings extends Equatable {
  final bool enableVoiceOver; // تفعيل قارئ الشاشة
  final bool highContrastMode; // وضع التباين العالي
  final double textScaleFactor; // معامل تكبير النص
  final bool reducedMotion; // تقليل الحركة
  final bool enableHapticFeedback; // تفعيل الاستجابة اللمسية
  final VoiceGender voiceGender; // جنس الصوت
  final double voiceSpeed; // سرعة الصوت

  const AccessibilitySettings({
    this.enableVoiceOver = false,
    this.highContrastMode = false,
    this.textScaleFactor = 1.0,
    this.reducedMotion = false,
    this.enableHapticFeedback = true,
    this.voiceGender = VoiceGender.male,
    this.voiceSpeed = 1.0,
  });

  AccessibilitySettings copyWith({
    bool? enableVoiceOver,
    bool? highContrastMode,
    double? textScaleFactor,
    bool? reducedMotion,
    bool? enableHapticFeedback,
    VoiceGender? voiceGender,
    double? voiceSpeed,
  }) {
    return AccessibilitySettings(
      enableVoiceOver: enableVoiceOver ?? this.enableVoiceOver,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      voiceGender: voiceGender ?? this.voiceGender,
      voiceSpeed: voiceSpeed ?? this.voiceSpeed,
    );
  }

  @override
  List<Object> get props => [
        enableVoiceOver,
        highContrastMode,
        textScaleFactor,
        reducedMotion,
        enableHapticFeedback,
        voiceGender,
        voiceSpeed,
      ];
}

/// جنس الصوت
enum VoiceGender {
  male('ذكر', 'Male'),
  female('أنثى', 'Female');

  const VoiceGender(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}
