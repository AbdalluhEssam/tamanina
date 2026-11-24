import 'package:shared_preferences/shared_preferences.dart';

/// فئة إدارة إعدادات المصحف الشريف
class MushafSettings {
  static const String _fontSizeKey = 'mushaf_font_size';
  static const String _lineHeightKey = 'mushaf_line_height';
  static const String _showBasmalaKey = 'mushaf_show_basmala';
  static const String _darkModeKey = 'mushaf_dark_mode';
  static const String _readingThemeKey = 'mushaf_reading_theme';
  static const String _autoFitKey = 'mushaf_auto_fit';
  static const String _printLayoutKey = 'mushaf_print_layout';

  static const double defaultFontSize = 20.0;
  static const double defaultLineHeight = 1.6;
  static const String defaultFontFamily = 'Amiri';
  static const String defaultReadingTheme = 'light';
  static const bool defaultAutoFit = true;
  static const bool defaultPrintLayout = false;
  static const List<String> supportedFonts = [
    'Amiri',
    'Cairo',
    'Tajawal',
    'Scheherazade',
    'NotoNaskhArabic',
  ];

  // أسماء الخطوط باللغة العربية للعرض
  static const Map<String, String> fontDisplayNames = {
    'Amiri': 'الخط الأميري',
    'Scheherazade': 'خط النسخ القرآني (شهرزاد)',
    'NotoNaskhArabic': 'نوتو نسخ كلاسيكي',
    'Cairo': 'القاهرة (خط حديث)',
    'Tajawal': 'تجوال (خط مبسط)',
  };
  static const double minFontSize = 14.0;
  static const String _fontFamilyKey = 'mushaf_font_family';
  static const double maxFontSize = 32.0;
  static const double minLineHeight = 1.3;
  static const double maxLineHeight = 2.4;

  // الحصول على حجم الخط
  static Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? defaultFontSize;
  }

  // تعيين حجم الخط
  static Future<void> setFontSize(double fontSize) async {
    if (fontSize < minFontSize || fontSize > maxFontSize) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, fontSize);
  }

  // الحصول على ارتفاع السطر
  static Future<double> getLineHeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_lineHeightKey) ?? defaultLineHeight;
  }

  // تعيين ارتفاع السطر
  static Future<void> setLineHeight(double lineHeight) async {
    if (lineHeight < minLineHeight || lineHeight > maxLineHeight) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lineHeightKey, lineHeight);
  }

  // الحصول على حالة عرض البسملة
  static Future<bool> getShowBasmala() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showBasmalaKey) ?? true;
  }

  // تعيين حالة عرض البسملة
  static Future<void> setShowBasmala(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showBasmalaKey, show);
  }

  // الحصول على سمة القراءة (light, cream, dark)
  static Future<String> getReadingTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_readingThemeKey);
    if (saved != null) return saved;
    final dark = prefs.getBool(_darkModeKey) ?? false;
    return dark ? 'dark' : 'light';
  }

  // تعيين سمة القراءة
  static Future<void> setReadingTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readingThemeKey, theme);
    await prefs.setBool(_darkModeKey, theme == 'dark');
  }

  // الحصول على الوضع الليلي (للتوافق القديم)
  static Future<bool> getDarkMode() async {
    final theme = await getReadingTheme();
    return theme == 'dark';
  }

  // تعيين الوضع الليلي
  static Future<void> setDarkMode(bool darkMode) async {
    await setReadingTheme(darkMode ? 'dark' : 'light');
  }

  // الحصول على حالة الملاءمة التلقائية لمساحة القراءة
  static Future<bool> getAutoFit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoFitKey) ?? defaultAutoFit;
  }

  // تعيين الملاءمة التلقائية
  static Future<void> setAutoFit(bool autoFit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoFitKey, autoFit);
  }

  static Future<void> setPrintLayout(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_printLayoutKey, enabled);
  }

  // الحصول على نوع الخط
  static Future<String> getFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fontFamilyKey) ?? defaultFontFamily;
  }

  // تعيين نوع الخط
  static Future<void> setFontFamily(String fontFamily) async {
    final prefs = await SharedPreferences.getInstance();
    if (!supportedFonts.contains(fontFamily)) return;
    await prefs.setString(_fontFamilyKey, fontFamily);
  }

  // إعادة تعيين الإعدادات للقيم الافتراضية
  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, defaultFontSize);
    await prefs.setDouble(_lineHeightKey, defaultLineHeight);
    await prefs.setBool(_showBasmalaKey, true);
    await prefs.setBool(_darkModeKey, false);
    await prefs.setString(_readingThemeKey, defaultReadingTheme);
    await prefs.setBool(_autoFitKey, defaultAutoFit);
    await prefs.remove(_printLayoutKey);
    await prefs.setString(_fontFamilyKey, defaultFontFamily);
  }

  // الحصول على جميع الإعدادات
  static Future<MushafSettingsData> getAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = await getReadingTheme();
    return MushafSettingsData(
      fontSize: await getFontSize(),
      lineHeight: await getLineHeight(),
      showBasmala: await getShowBasmala(),
      darkMode: theme == 'dark',
      fontFamily: await getFontFamily(),
      readingTheme: theme,
      autoFit: await getAutoFit(),
      printLayout: prefs.getBool(_printLayoutKey) ?? defaultPrintLayout,
    );
  }
}

/// نموذج بيانات إعدادات المصحف
class MushafSettingsData {
  final double fontSize;
  final double lineHeight;
  final bool showBasmala;
  final bool darkMode;
  final String fontFamily;
  final String readingTheme;
  final bool autoFit;
  final bool printLayout;

  const MushafSettingsData({
    required this.fontSize,
    required this.lineHeight,
    required this.showBasmala,
    required this.darkMode,
    required this.fontFamily,
    this.readingTheme = 'light',
    this.autoFit = true,
    this.printLayout = MushafSettings.defaultPrintLayout,
  });

  double get fontScale => fontSize / MushafSettings.defaultFontSize;

  String get fontSizeLabel =>
      autoFit ? '${(fontScale * 100).round()}%' : '${fontSize.round()}';

  MushafSettingsData copyWith({
    double? fontSize,
    double? lineHeight,
    bool? showBasmala,
    bool? darkMode,
    String? fontFamily,
    String? readingTheme,
    bool? autoFit,
    bool? printLayout,
  }) {
    return MushafSettingsData(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      showBasmala: showBasmala ?? this.showBasmala,
      darkMode: darkMode ?? this.darkMode,
      fontFamily: fontFamily ?? this.fontFamily,
      readingTheme: readingTheme ?? this.readingTheme,
      autoFit: autoFit ?? this.autoFit,
      printLayout: printLayout ?? this.printLayout,
    );
  }
}
