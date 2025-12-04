import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/services/mushaf_settings.dart';

/// شاشة إعدادات المصحف الشريف
class MushafSettingsScreen extends StatefulWidget {
  const MushafSettingsScreen({super.key});

  @override
  State<MushafSettingsScreen> createState() => _MushafSettingsScreenState();
}

class _MushafSettingsScreenState extends State<MushafSettingsScreen> {
  MushafSettingsData? settings;
  bool isLoading = true;
  List<String> availableFonts = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsData = await MushafSettings.getAllSettings();
      // load supported fonts from utility
      availableFonts = MushafSettings.supportedFonts;
      setState(() {
        settings = settingsData;
        isLoading = false;
      });
    } catch (e) {
      print('خطأ في تحميل الإعدادات: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateFontSize(double newSize) async {
    await MushafSettings.setFontSize(newSize);
    setState(() {
      settings = settings?.copyWith(fontSize: newSize);
    });
  }

  Future<void> _updateLineHeight(double newHeight) async {
    await MushafSettings.setLineHeight(newHeight);
    setState(() {
      settings = settings?.copyWith(lineHeight: newHeight);
    });
  }

  Future<void> _updateShowBasmala(bool show) async {
    await MushafSettings.setShowBasmala(show);
    setState(() {
      settings = settings?.copyWith(showBasmala: show);
    });
  }

  Future<void> _updateDarkMode(bool darkMode) async {
    await MushafSettings.setDarkMode(darkMode);
    setState(() {
      settings = settings?.copyWith(darkMode: darkMode);
    });
  }

  Future<void> _updateFontFamily(String newFont) async {
    await MushafSettings.setFontFamily(newFont);
    setState(() {
      settings = settings?.copyWith(fontFamily: newFont);
    });
  }

  Future<void> _resetSettings() async {
    await MushafSettings.resetToDefaults();
    await _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: settings?.darkMode == true
          ? const Color(0xFF0d1117) // نفس اللون المستخدم في المصحف
          : const Color(0xFFF5F5DC),
      appBar: _buildAppBar(),
      body: isLoading ? _buildLoadingState() : _buildSettingsContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isDark = settings?.darkMode == true;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'إعدادات المصحف',
        style: AppTypography.h6Arabic.copyWith(
          color: isDark ? Colors.white : Colors.brown,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : Colors.brown,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _resetSettings,
          tooltip: 'إعادة تعيين',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildSettingsContent() {
    if (settings == null) return const SizedBox.shrink();

    final isDark = settings!.darkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Colors.grey[800] : Colors.white;

    return SingleChildScrollView(
      // padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // بطاقة إعدادات النص
          _buildSettingsCard(
            title: 'إعدادات النص',
            icon: Icons.text_fields,
            color: cardColor!,
            textColor: textColor,
            children: [
              _buildFontSizeSlider(textColor),
              SizedBox(height: 12.h),
              _buildFontFamilySelector(textColor),
              SizedBox(height: 16.h),
              _buildLineHeightSlider(textColor),
              SizedBox(height: 16.h),
              _buildTextPreview(),
            ],
          ),

          // بطاقة إعدادات العرض
          _buildSettingsCard(
            title: 'إعدادات العرض',
            icon: Icons.visibility,
            color: cardColor,
            textColor: textColor,
            children: [
              _buildBasmalaSetting(textColor),
              SizedBox(height: 16.h),
              _buildDarkModeSetting(textColor),
            ],
          ),

          // معلومات إضافية
          _buildInfoCard(cardColor, textColor),

          // أزرار الإجراءات
          _buildActionButtons(),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color textColor,
    required List<Widget> children,
  }) {
    return Card(
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.brown, size: 24.w),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: AppTypography.h6Arabic.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'حجم الخط',
              style: AppTypography.bodyMediumArabic.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${settings!.fontSize.toInt()}',
                style: AppTypography.bodySmallArabic.copyWith(
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.brown,
            inactiveTrackColor: Colors.brown.withOpacity(0.3),
            thumbColor: Colors.brown,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
          ),
          child: Slider(
            value: settings!.fontSize,
            min: MushafSettings.minFontSize,
            max: MushafSettings.maxFontSize,
            divisions:
                ((MushafSettings.maxFontSize - MushafSettings.minFontSize) / 2)
                    .round(),
            onChanged: _updateFontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildLineHeightSlider(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ارتفاع السطر',
              style: AppTypography.bodyMediumArabic.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                settings!.lineHeight.toStringAsFixed(1),
                style: AppTypography.bodySmallArabic.copyWith(
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.brown,
            inactiveTrackColor: Colors.brown.withOpacity(0.3),
            thumbColor: Colors.brown,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
          ),
          child: Slider(
            value: settings!.lineHeight,
            min: MushafSettings.minLineHeight,
            max: MushafSettings.maxLineHeight,
            divisions: 13, // من 1.2 إلى 2.5 بخطوات 0.1
            onChanged: _updateLineHeight,
          ),
        ),
      ],
    );
  }

  Widget _buildTextPreview() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: settings!.darkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.brown.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.brown.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'معاينة النص',
            style: _withSelectedFont(AppTypography.captionArabic.copyWith(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            )),
          ),
          SizedBox(height: 8.h),
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ﴿١﴾ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ﴿٢﴾',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: _withSelectedFont(AppTypography.bodyLargeArabic.copyWith(
              fontSize: settings!.fontSize.sp,
              height: settings!.lineHeight,
              color: settings!.darkMode ? Colors.white : Colors.black87,
            )),
          ),
        ],
      ),
    );
  }

  // Apply the selected mushaf font to a base TextStyle for immediate preview
  TextStyle _withSelectedFont(TextStyle base) {
    final font = settings?.fontFamily ?? MushafSettings.defaultFontFamily;
    try {
      switch (font) {
        case 'Amiri':
          return GoogleFonts.amiri(textStyle: base);
        case 'Cairo':
          return GoogleFonts.cairo(textStyle: base);
        case 'Tajawal':
          return GoogleFonts.tajawal(textStyle: base);
        case 'NotoNaskhArabic':
          return GoogleFonts.notoNaskhArabic(textStyle: base);
        case 'Scheherazade':
          return GoogleFonts.getFont('Scheherazade', textStyle: base);
        default:
          return GoogleFonts.getFont(font, textStyle: base);
      }
    } catch (e) {
      return base;
    }
  }

  Widget _buildFontFamilySelector(Color textColor) {
    if (availableFonts.isEmpty || settings == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الخط',
          style: AppTypography.bodyMediumArabic.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownMenu<String>(
          width: 300.w, // ده بيخلي الـ field نفسه يتمدد
          initialSelection: settings!.fontFamily,
          label: Text(
            "اختر الخط",
            style: AppTypography.bodyMediumArabic.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.brown,
            ),
          ),
          textStyle: AppTypography.bodyMediumArabic.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          trailingIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.brown,
          ),
          menuStyle: MenuStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: Colors.brown.withOpacity(0.2)),
              ),
            ),
            fixedSize: WidgetStateProperty.all(
              Size(90.w, 240.h), // 👈 عرض 90px وارتفاع 250px
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.brown.withOpacity(0.06),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.brown.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.brown, width: 1.5),
            ),
          ),
          dropdownMenuEntries: availableFonts.map((f) {
            return DropdownMenuEntry<String>(
              value: f,
              label: MushafSettings.fontDisplayNames[f] ?? f,
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all(
                  AppTypography.bodyMediumArabic.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            );
          }).toList(),
          onSelected: (v) {
            if (v == null) return;
            _updateFontFamily(v);
          },
        )
      ],
    );
  }

  Widget _buildBasmalaSetting(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إظهار البسملة',
              style: AppTypography.bodyMediumArabic.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'إظهار البسملة في بداية كل سورة',
              style: AppTypography.captionArabic.copyWith(
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
        Switch(
          value: settings!.showBasmala,
          onChanged: _updateShowBasmala,
          activeColor: Colors.brown,
          activeTrackColor: Colors.brown.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildDarkModeSetting(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الوضع الليلي',
              style: AppTypography.bodyMediumArabic.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'تفعيل المظهر الداكن',
              style: AppTypography.captionArabic.copyWith(
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
        Switch(
          value: settings!.darkMode,
          onChanged: _updateDarkMode,
          activeColor: Colors.brown,
          activeTrackColor: Colors.brown.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildInfoCard(Color cardColor, Color textColor) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue, size: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'الإعدادات يتم حفظها تلقائياً وسيتم تطبيقها عند العودة للمصحف',
                style: AppTypography.captionArabic.copyWith(
                  color: textColor.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _resetSettings,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'إعادة تعيين',
                style: AppTypography.labelMediumArabic.copyWith(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                'تم',
                style: AppTypography.labelMediumArabic.copyWith(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
