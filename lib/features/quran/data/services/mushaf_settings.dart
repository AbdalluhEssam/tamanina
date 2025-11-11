import 'package:shared_preferences/shared_preferences.dart';

/// فئة إدارة إعدادات المصحف الشريف
class MushafSettings {
  static const String _fontSizeKey = 'mushaf_font_size';
  static const String _lineHeightKey = 'mushaf_line_height';
  static const String _showBasmalaKey = 'mushaf_show_basmala';
  static const String _darkModeKey = 'mushaf_dark_mode';

  // القيم الافتراضية
  static const double defaultFontSize = 18.0;
  static const double defaultLineHeight = 1.8;
  static const String defaultFontFamily = 'Amiri';
  static const List<String> supportedFonts = [
    'Amiri',
    'Cairo',
    'Tajawal',
    'Scheherazade',
    'NotoNaskhArabic',
  ];

  // أسماء الخطوط باللغة العربية للعرض
  static const Map<String, String> fontDisplayNames = {
    'Amiri': 'أميري',
    'Cairo': 'القاهرة',
    'Tajawal': 'تجوال',
    'Scheherazade': 'شهرزاد',
    'NotoNaskhArabic': 'نوتو نسخ عربي',
  };
  static const double minFontSize = 12.0;
  static const String _fontFamilyKey = 'mushaf_font_family';
  static const double maxFontSize = 32.0;
  static const double minLineHeight = 1.2;
  static const double maxLineHeight = 2.5;

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

  // الحصول على الوضع الليلي
  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  // تعيين الوضع الليلي
  static Future<void> setDarkMode(bool darkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, darkMode);
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
    await prefs.setString(_fontFamilyKey, defaultFontFamily);
  }

  // الحصول على جميع الإعدادات
  static Future<MushafSettingsData> getAllSettings() async {
    return MushafSettingsData(
      fontSize: await getFontSize(),
      lineHeight: await getLineHeight(),
      showBasmala: await getShowBasmala(),
      darkMode: await getDarkMode(),
      fontFamily: await getFontFamily(),
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

  const MushafSettingsData({
    required this.fontSize,
    required this.lineHeight,
    required this.showBasmala,
    required this.darkMode,
    required this.fontFamily,
  });

  MushafSettingsData copyWith({
    double? fontSize,
    double? lineHeight,
    bool? showBasmala,
    bool? darkMode,
    String? fontFamily,
  }) {
    return MushafSettingsData(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      showBasmala: showBasmala ?? this.showBasmala,
      darkMode: darkMode ?? this.darkMode,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}
