import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_sharif/quran_sharif.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/reading_position_manager.dart';
import '../../utils/mushaf_settings.dart';
import 'mushaf_settings_screen.dart';

/// شاشة المصحف الشريف - تصميم محسّن مع صفحة واحدة
class SimpleMushafPageScreen extends StatefulWidget {
  final int initialPage;
  final int? initialSurah; // إضافة للانتقال لسورة معينة

  const SimpleMushafPageScreen({
    super.key,
    this.initialPage = 1,
    this.initialSurah,
  });

  @override
  State<SimpleMushafPageScreen> createState() => _SimpleMushafPageScreenState();
}

class _SimpleMushafPageScreenState extends State<SimpleMushafPageScreen> {
  late PageController _pageController;
  int currentPageNumber = 1;
  List<QuranPageData> allPages = [];
  bool isLoading = true;
  String? error;

  // إعدادات المصحف
  MushafSettingsData? settings;
  double currentFontSize = 18.0;
  double currentLineHeight = 1.8;
  bool showBasmala = true;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    currentPageNumber = widget.initialPage;
    _setupPageController();
    _loadSettings();
    _loadQuranPages();
    _loadSavedPage();
  }

  Future<void> _loadSettings() async {
    try {
      settings = await MushafSettings.getAllSettings();
      if (mounted) {
        setState(() {
          currentFontSize = settings!.fontSize;
          currentLineHeight = settings!.lineHeight;
          showBasmala = settings!.showBasmala;
          isDarkMode = settings!.darkMode;
          // apply font family if provided
          // AppTypography uses font fallback; we pass fontFamily directly where needed
        });
      }
    } catch (e) {
      print('خطأ في تحميل الإعدادات: $e');
    }
  }

  void _loadSavedPage() async {
    try {
      // انتظار تحميل البيانات أولاً
      while (allPages.isEmpty && isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // إذا كان هناك سورة محددة، ابحث عن صفحتها
      if (widget.initialSurah != null) {
        await _navigateToSurah(widget.initialSurah!);
        return;
      }

      final savedPage = await ReadingPositionManager.getCurrentPage();
      if (savedPage != currentPageNumber && mounted) {
        setState(() {
          currentPageNumber = savedPage;
        });
        _setupPageController(); // إعادة تعيين PageController للصفحة الجديدة
      }
    } catch (e) {
      print('خطأ في تحميل الصفحة المحفوظة: $e');
    }
  }

  Future<void> _navigateToSurah(int surahNumber) async {
    // ابحث عن الصفحة التي تحتوي على بداية السورة
    try {
      print('🔍 البحث عن السورة رقم $surahNumber...');

      for (int pageIndex = 0; pageIndex < allPages.length; pageIndex++) {
        final pageData = allPages[pageIndex];
        if (pageData.ayahs.isNotEmpty) {
          // تحقق من جميع الآيات في الصفحة للعثور على بداية السورة
          for (final ayah in pageData.ayahs) {
            // إذا وجدت الآية الأولى من السورة المطلوبة
            if (ayah.numberInSurah == 1) {
              // نحتاج للتحقق من رقم السورة، لكن Ayah لا يحتوي على رقم السورة
              // سنستعمل mainSurahNumber كتقريب
              if (pageData.mainSurahNumber == surahNumber) {
                print(
                    '✅ تم العثور على السورة $surahNumber في الصفحة ${pageIndex + 1}');
                setState(() {
                  currentPageNumber = pageIndex + 1;
                });
                _setupPageController();
                return;
              }
            }
          }

          // إذا لم نجد بداية السورة، تحقق من السورة الرئيسية في الصفحة
          if (pageData.mainSurahNumber == surahNumber) {
            print(
                '✅ تم العثور على السورة $surahNumber في الصفحة ${pageIndex + 1}');
            setState(() {
              currentPageNumber = pageIndex + 1;
            });
            _setupPageController();
            return;
          }
        }
      }

      print('⚠️ لم يتم العثور على السورة $surahNumber');
    } catch (e) {
      print('❌ خطأ في العثور على السورة: $e');
    }
  }

  void _saveCurrentPage() async {
    try {
      await ReadingPositionManager.saveCurrentPage(currentPageNumber);
    } catch (e) {
      print('خطأ في حفظ الصفحة: $e');
    }
  }

  void _setupPageController() {
    // الصفحة الأولية
    int initialPageIndex = currentPageNumber - 1; // تحويل إلى index
    _pageController = PageController(initialPage: initialPageIndex);
  }

  Future<void> _loadQuranPages() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // تحميل جميع السور
      final surahs = Quran.getAllSurah();
      print('✅ تم تحميل ${surahs.length} سورة');

      allPages.clear();

      // إنشاء صفحة منفصلة لكل سورة مع تنظيف البسملة
      for (final surah in surahs) {
        print('🔄 معالجة سورة ${surah.name} (رقم ${surah.number})');

        // تنظيف آيات السورة من البسملة المدمجة
        List<Ayahs> cleanedAyahs = [];

        for (int ayahIndex = 0; ayahIndex < surah.ayahs.length; ayahIndex++) {
          final ayah = surah.ayahs[ayahIndex];
          String originalText = ayah.text.trim();

          // طباعة الآية الأولى للفحص
          if (ayahIndex == 0) {
            print('📖 أول آية في سورة ${surah.name}: "$originalText"');
          }

          // إزالة البسملة من الآية الأولى في كل سورة (عدا الفاتحة)
          String cleanedText = originalText;
          if (ayahIndex == 0 && surah.number != 1) {
            // قائمة شاملة للبسملة (الشكل الصحيح أولاً)
            List<String> basmalaVariations = [
              // الشكل الصحيح من المكتبة
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
              // أشكال أخرى محتملة
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              'بسم الله الرحمن الرحيم',
              'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيمِ',
              'بسم اللّه الرحمن الرحيم',
            ];

            bool basmalaFound = false;
            for (String basmala in basmalaVariations) {
              if (cleanedText.startsWith(basmala)) {
                cleanedText = cleanedText.replaceFirst(basmala, '').trim();
                print('🧹 تم تنظيف البسملة من أول آية في سورة ${surah.name}');
                basmalaFound = true;
                break;
              }
            }

            // إزالة بـ RegEx كاحتياط
            if (!basmalaFound) {
              RegExp basmalaRegex = RegExp(
                  r'بِ?سْ?مِ\s+اللَّ?هِ\s+الرَّ?حْ?مَ?ٰ?نِ\s+الرَّ?حِيمِ',
                  caseSensitive: false);
              if (basmalaRegex.hasMatch(cleanedText)) {
                cleanedText = cleanedText.replaceAll(basmalaRegex, '').trim();
                print('🧹 تم تنظيف البسملة بـ RegEx من سورة ${surah.name}');
              }
            }

            // تنظيف المسافات الزائدة
            cleanedText = cleanedText.replaceAll(RegExp(r'\s+'), ' ').trim();

            // طباعة النتيجة للفحص
            if (cleanedText != originalText) {
              print('✨ سورة ${surah.name} - قبل: "$originalText"');
              print('✨ سورة ${surah.name} - بعد: "$cleanedText"');
            }
          }

          // إنشاء آية جديدة بالنص المنظف
          final cleanedAyah = Ayahs(
            number: ayah.number,
            text: cleanedText,
            numberInSurah: ayah.numberInSurah,
            juz: ayah.juz,
            manzil: ayah.manzil,
            page: ayah.page,
            ruku: ayah.ruku,
            hizbQuarter: ayah.hizbQuarter,
            sajda: ayah.sajda,
            audio: ayah.audio,
            audioSecondary: ayah.audioSecondary,
          );
          cleanedAyahs.add(cleanedAyah);
        }

        // تجميع الآيات في صفحات (حوالي 15 آية لكل صفحة)
        const int ayahsPerPage = 15;

        for (int i = 0; i < cleanedAyahs.length; i += ayahsPerPage) {
          int endIndex = i + ayahsPerPage;
          if (endIndex > cleanedAyahs.length) endIndex = cleanedAyahs.length;

          List<Ayahs> pageAyahs = cleanedAyahs.sublist(i, endIndex);

          // إنشاء بيانات الصفحة
          allPages.add(QuranPageData(
            pageNumber: allPages.length + 1,
            ayahs: pageAyahs,
            surahInfo: 'سورة ${surah.name}',
            mainSurahNumber: surah.number,
            isFirstPageOfSurah: i == 0, // لتحديد إذا كانت أول صفحة في السورة
          ));
        }
      }

      print('✅ تم توزيع السور على ${allPages.length} صفحة');

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('❌ خطأ في تحميل القرآن: $e');
      setState(() {
        isLoading = false;
        error = 'خطأ في تحميل البيانات: $e';
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0d1117) // أسود عميق للدارك مود
          : const Color(0xFFF5F5DC), // لون ورقي كلاسيكي
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\u0627\u0644\u0645\u0635\u062d\u0641 \u0627\u0644\u0634\u0631\u064a\u0641',
            style: _withSelectedFont(AppTypography.h6Arabic.copyWith(
              color: isDarkMode ? Colors.white : Colors.brown,
              fontWeight: FontWeight.bold,
            )),
          ),
          if (settings != null)
            Text(
              settings!.fontFamily,
              style: AppTypography.captionArabic.copyWith(
                color:
                    isDarkMode ? Colors.white70 : Colors.brown.withOpacity(0.8),
                fontSize: 12.sp,
              ),
            ),
        ],
      ),
      centerTitle: true,
      iconTheme: IconThemeData(
        color: isDarkMode ? Colors.white : Colors.brown,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_border),
          onPressed: _showBookmarks,
          tooltip: 'العلامات المرجعية',
        ),
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: _showHistory,
          tooltip: 'تاريخ القراءة',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showSettings,
          tooltip: 'الإعدادات',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (error != null) {
      return _buildErrorState();
    }

    if (allPages.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPagesView();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.brown,
            strokeWidth: 3.w,
          ),
          SizedBox(height: 20.h),
          Text(
            'جارٍ تحميل المصحف الشريف...',
            style: _withSelectedFont(AppTypography.bodyLargeArabic.copyWith(
              color: Colors.brown,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.w,
            color: Colors.red,
          ),
          SizedBox(height: 20.h),
          Text(
            'حدث خطأ في التحميل',
            style: _withSelectedFont(AppTypography.h6Arabic.copyWith(
              color: Colors.red,
            )),
          ),
          SizedBox(height: 10.h),
          Text(
            error ?? '',
            textAlign: TextAlign.center,
            style: _withSelectedFont(AppTypography.bodyMediumArabic),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: _loadQuranPages,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'لا توجد بيانات',
        style: _withSelectedFont(AppTypography.h6Arabic),
      ),
    );
  }

  Widget _buildPagesView() {
    // عرض صفحة واحدة فقط في كل مرة
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: allPages.length, // صفحة واحدة لكل عنصر
      itemBuilder: (context, pageIndex) {
        return _buildSinglePageView(pageIndex);
      },
    );
  }

  Widget _buildSinglePageView(int pageIndex) {
    if (pageIndex >= allPages.length) {
      return Container(); // صفحة فارغة
    }

    final pageAyahs = allPages[pageIndex];
    final pageNumber = pageIndex + 1;

    return Container(
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF161b22) // لون داكن مريح للعين
            : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.5)
                : Colors.brown.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: isDarkMode
            ? Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              )
            : null,
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // رأس الصفحة
            _buildPageHeader(pageNumber),

            SizedBox(height: 16.h),

            // محتوى الصفحة
            Expanded(
              child: _buildPageContent(pageAyahs.ayahs),
            ),

            SizedBox(height: 16.h),

            // تذييل الصفحة
            _buildPageFooter(pageNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(int pageNumber) {
    // الحصول على معلومات السورة للصفحة الحالية
    String surahName = '';

    if (pageNumber <= allPages.length) {
      final pageData = allPages[pageNumber - 1];
      if (pageData.surahInfo != null) {
        // إزالة كلمة "سورة" المكررة وإظهار اسم السورة فقط
        surahName = pageData.surahInfo!
            .replaceAll('سورة ', '')
            .replaceAll('صفحة $pageNumber', '')
            .trim();
      }
    }

    if (surahName.isEmpty) {
      surahName = 'المصحف الشريف';
    }

    return Center(
      child: Container(
        width: double.infinity, // تحديد عرض أقصى للهيدر
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDarkMode
                  ? Colors.amber.withOpacity(0.2)
                  : Colors.brown.withOpacity(0.15),
              isDarkMode
                  ? Colors.amber.withOpacity(0.1)
                  : Colors.brown.withOpacity(0.08),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: isDarkMode
                ? Colors.amber.withOpacity(0.4)
                : Colors.brown.withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius:
              BorderRadius.circular(25.r), // حواف دائرية أكثر مثل المصاحف
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.amber.withOpacity(0.15)
                  : Colors.brown.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              surahName,
              textAlign: TextAlign.center,
              style: _withSelectedFont(
                AppTypography.h6Arabic.copyWith(
                  color: isDarkMode ? Colors.amber : Colors.brown,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp, // خط أصغر
                ),
              ),
            ),
            // if (surahDetails.isNotEmpty) ...[
            //   SizedBox(width: 8.w),
            //   Text(
            //     surahDetails,
            //     textAlign: TextAlign.center,
            //     style: AppTypography.captionArabic.copyWith(
            //       color: isDarkMode
            //           ? Colors.amber.withOpacity(0.8)
            //           : Colors.brown.withOpacity(0.8),
            //       fontSize: 9.sp, // خط أصغر للتفاصيل
            //       fontWeight: FontWeight.w400,
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(List<Ayahs> ayahs) {
    int pageIndex = currentPageNumber - 1;
    bool isFirstPageOfSurah = false;
    int? surahNumber;

    if (pageIndex < allPages.length) {
      isFirstPageOfSurah = allPages[pageIndex].isFirstPageOfSurah;
      surahNumber = allPages[pageIndex].mainSurahNumber;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // عرض البسملة في أول صفحة من السورة (عدا الفاتحة والتوبة) وحسب الإعدادات
          if (showBasmala &&
              isFirstPageOfSurah &&
              surahNumber != null &&
              surahNumber != 9)
            _buildBasmala(),

          // محتوى الآيات
          _buildVersesContent(ayahs),
        ],
      ),
    );
  }

  Widget _buildBasmala() {
    return Text(
      '\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0644\u064e\u0651\u0647\u0650 \u0627\u0644\u0631\u064e\u0651\u062d\u0652\u0645\u064e\u0670\u0646\u0650 \u0627\u0644\u0631\u064e\u0651\u062d\u0650\u064a\u0645\u0650',
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      style: _withSelectedFont(
        AppTypography.h4Arabic.copyWith(
          fontSize: (currentFontSize + 4).sp,
          height: currentLineHeight,
          color: isDarkMode ? Colors.amber : Colors.brown,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildVersesContent(List<Ayahs> ayahs) {
    // تحويل كل الآيات إلى نص واحد متصل
    List<TextSpan> textSpans = [];

    for (int i = 0; i < ayahs.length; i++) {
      final ayah = ayahs[i];
      String ayahText = ayah.text.trim();

      // إزالة البسملة من بداية الآية الأولى فقط لكل سورة
      if (ayah.numberInSurah == 1) {
        // قائمة شاملة بجميع أشكال البسملة المحتملة
        List<String> basmalaVariations = [
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
          'بسم الله الرحمن الرحيم',
          'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيمِ',
          'بسم اللّه الرحمن الرحيم',
          'بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ',
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَنِ ٱلرَّحِيمِ',
          'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          'بسم الله',
          'بِسْمِ الله',
        ];

        // إزالة البسملة من البداية
        for (String basmala in basmalaVariations) {
          if (ayahText.startsWith(basmala)) {
            ayahText = ayahText.substring(basmala.length).trim();
            print('🔥 تم إزالة البسملة من الآية الأولى: $basmala');
            break;
          }
        }

        // إذا لم تنجح الطريقة الأولى، جرب Regex
        if (ayahText == ayah.text.trim()) {
          // نمط Regex شامل للبسملة بجميع أشكالها
          final basmalaRegex = RegExp(
              r'^بِ?سْ?مِ?\s*اللَّ?هِ?\s*الرَّ?حْ?مَ?ٰ?نِ?\s*الرَّ?حِيمِ\s*',
              caseSensitive: false,
              unicode: true);

          // إزالة البسملة من بداية النص
          ayahText = ayahText.replaceFirst(basmalaRegex, '').trim();
          print('🔥 تم إزالة البسملة باستخدام Regex');
        }
      }

      // تنظيف النص من المسافات الزائدة
      ayahText = ayahText
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll(RegExp(r'^\s+|\s+$'), '')
          .trim();

      // تجاهل الآية إذا كانت فارغة بعد الإزالة
      if (ayahText.isEmpty) {
        print('⏭️ تم تجاهل آية فارغة بعد إزالة البسملة');
        continue;
      }

      // إضافة نص الآية
      textSpans.add(
        TextSpan(
          text: ayahText,
          style: _withSelectedFont(AppTypography.bodyLargeArabic.copyWith(
            fontSize: currentFontSize.sp,
            height: currentLineHeight,
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w400,
          )),
        ),
      );

      // إضافة رقم الآية بتصميم محسن
      textSpans.add(
        TextSpan(
          text: ' ﴿${ayah.numberInSurah}﴾ ',
          style: _withSelectedFont(AppTypography.bodyLargeArabic.copyWith(
            color: isDarkMode ? Colors.amber : Colors.brown,
            fontWeight: FontWeight.bold,
            fontSize: (currentFontSize - 2).sp,
          )),
        ),
      );

      // إضافة مسافة بين الآيات (إلا إذا كانت آخر آية)
      if (i < ayahs.length - 1) {
        textSpans.add(
          TextSpan(
            text: '  ',
            style: _withSelectedFont(AppTypography.bodyLargeArabic.copyWith(
              fontSize: currentFontSize.sp,
            )),
          ),
        );
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12.r),
        border: isDarkMode
            ? Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              )
            : null,
      ),
      child: RichText(
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        text: TextSpan(
          children: textSpans,
        ),
      ),
    );
  }

// دالة مساعدة للتحقق إذا كان النص هو البسملة فقط
  bool _isBasmalaOnly(String text) {
    final cleanedText = text.trim();

    // قائمة بجميع أشكال البسملة الكاملة
    final fullBasmalaList = [
      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
      'بسم الله الرحمن الرحيم',
      'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيمِ',
      'بسم اللّه الرحمن الرحيم',
      'بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ',
      'بِسْمِ ٱللَّهِ ٱلرَّحْمَنِ ٱلرَّحِيمِ',
    ];

    // إذا كان النص مطابقًا لأي شكل من أشكال البسملة الكاملة
    if (fullBasmalaList.contains(cleanedText)) {
      return true;
    }

    // استخدام Regex للتحقق من البسملة بأنواعها المختلفة
    final basmalaRegex = RegExp(
        r'^بِ?سْ?مِ?\s*اللَّ?هِ?\s*(الرَّ?حْ?مَ?ٰ?نِ?\s*الرَّ?حِيمِ)?$',
        caseSensitive: false,
        unicode: true);

    return basmalaRegex.hasMatch(cleanedText);
  }

// دالة مساعدة للتحقق إذا كان النص يحتوي فقط على كلمات البسملة
  bool _containsOnlyBasmalaWords(String text) {
    final cleanedText = text.trim();
    final basmalaWords = [
      'بسم',
      'بِسْمِ',
      'الله',
      'اللَّهِ',
      'الرحمن',
      'الرَّحْمَٰنِ',
      'الرحيم',
      'الرَّحِيمِ'
    ];

    // تقسيم النص إلى كلمات والتحقق إذا كانت جميعها من كلمات البسملة
    final words = cleanedText.split(RegExp(r'\s+'));
    return words.every((word) => basmalaWords.contains(word));
  }

  String _removeBasmala(String ayahText) {
    // نمط Regex شامل للبسملة بجميع أشكالها
    final basmalaRegex = RegExp(
        r'بِ?سْ?مِ?\s*اللَّ?هِ?\s*الرَّ?حْ?مَ?ٰ?نِ?\s*الرَّ?حِيمِ\s*',
        caseSensitive: false,
        unicode: true);

    // إزالة البسملة من بداية النص
    String result = ayahText.replaceFirst(basmalaRegex, '').trim();

    // إذا لم يتم إزالة anything، جرب إزالتها من أي مكان في النص
    if (result == ayahText) {
      result = ayahText.replaceAll(basmalaRegex, '').trim();
    }

    return result;
  }

  Widget _buildPageFooter(int pageNumber) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // رقم الصفحة بتصميم محسن
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDarkMode
                    ? Colors.amber.withOpacity(0.15)
                    : Colors.brown.withOpacity(0.1),
                isDarkMode
                    ? Colors.amber.withOpacity(0.08)
                    : Colors.brown.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDarkMode
                  ? Colors.amber.withOpacity(0.4)
                  : Colors.brown.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_outline,
                size: 14.w,
                color: isDarkMode ? Colors.amber : Colors.brown,
              ),
              SizedBox(width: 6.w),
              Text(
                pageNumber.toString(),
                style: _withSelectedFont(AppTypography.captionArabic.copyWith(
                  color: isDarkMode ? Colors.amber : Colors.brown,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                )),
              ),
            ],
          ),
        ),

        // زر إضافة علامة مرجعية محسن
        Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.amber.withOpacity(0.15)
                : Colors.brown.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDarkMode
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.brown.withOpacity(0.3),
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.bookmark_add,
              color: isDarkMode ? Colors.amber : Colors.brown,
              size: 18.w,
            ),
            onPressed: () => _addBookmark(pageNumber),
            tooltip: 'إضافة علامة مرجعية',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    int totalPages = allPages.length;

    return Container(
      height: 80.h,
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 12.h,
        bottom: 20.h,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF161b22) : Colors.white,
        border: isDarkMode
            ? Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الصفحة السابقة
          IconButton(
            onPressed: _canGoPrevious() ? _goToPreviousPage : null,
            icon: Icon(
              Icons.arrow_back_ios,
              color: _canGoPrevious()
                  ? (isDarkMode ? Colors.amber : Colors.brown)
                  : Colors.grey,
            ),
          ),

          // مؤشر الصفحة الحالية
          GestureDetector(
            onTap: _showPageNavigator,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.amber.withOpacity(0.15)
                    : Colors.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.amber.withOpacity(0.4)
                      : Colors.brown.withOpacity(0.3),
                ),
              ),
              child: Text(
                '$currentPageNumber من $totalPages',
                style:
                    _withSelectedFont(AppTypography.bodyMediumArabic.copyWith(
                  color: isDarkMode ? Colors.amber : Colors.brown,
                  fontWeight: FontWeight.bold,
                )),
              ),
            ),
          ),

          // زر الصفحة التالية
          IconButton(
            onPressed: _canGoNext() ? _goToNextPage : null,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: _canGoNext()
                  ? (isDarkMode ? Colors.amber : Colors.brown)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  bool _canGoPrevious() => currentPageNumber > 1;

  bool _canGoNext() => currentPageNumber < allPages.length;

  void _onPageChanged(int pageIndex) {
    setState(() {
      currentPageNumber = pageIndex + 1; // الصفحة الحقيقية
    });
    _saveCurrentPage(); // حفظ الصفحة الحالية
  }

  void _goToPreviousPage() {
    if (_canGoPrevious()) {
      int newPageIndex = currentPageNumber - 2; // الصفحة السابقة
      if (newPageIndex >= 0) {
        _pageController.animateToPage(
          newPageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _goToNextPage() {
    if (_canGoNext()) {
      int newPageIndex = currentPageNumber; // الصفحة التالية
      if (newPageIndex < allPages.length) {
        _pageController.animateToPage(
          newPageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _showPageNavigator() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'انتقل إلى صفحة',
              style: _withSelectedFont(AppTypography.h6Arabic.copyWith(
                fontWeight: FontWeight.bold,
              )),
            ),
            SizedBox(height: 20.h),
            TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'رقم الصفحة (1-${allPages.length})',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onSubmitted: (value) {
                final pageNum = int.tryParse(value);
                if (pageNum != null &&
                    pageNum >= 1 &&
                    pageNum <= allPages.length) {
                  _navigateToPage(pageNum);
                  Navigator.pop(context);
                }
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(int pageNumber) {
    setState(() {
      currentPageNumber = pageNumber;
    });
    int pageIndex = pageNumber - 1; // تحويل إلى index
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _saveCurrentPage(); // حفظ الصفحة الجديدة
  }

  // وظائف العلامات المرجعية والتاريخ
  void _addBookmark(int pageNumber) async {
    try {
      await ReadingPositionManager.addBookmark(pageNumber, 'صفحة $pageNumber');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إضافة علامة مرجعية للصفحة $pageNumber'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('خطأ في إضافة العلامة المرجعية: $e');
    }
  }

  void _showBookmarks() async {
    try {
      final bookmarks = await ReadingPositionManager.getBookmarks();
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) => Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'العلامات المرجعية',
                style: _withSelectedFont(AppTypography.h6Arabic.copyWith(
                  fontWeight: FontWeight.bold,
                )),
              ),
              SizedBox(height: 20.h),
              if (bookmarks.isEmpty)
                Text(
                  'لا توجد علامات مرجعية',
                  style:
                      _withSelectedFont(AppTypography.bodyMediumArabic.copyWith(
                    color: Colors.grey,
                  )),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: bookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = bookmarks[index];
                      return ListTile(
                        leading:
                            const Icon(Icons.bookmark, color: Colors.brown),
                        title: Text(bookmark.title),
                        subtitle: Text('الصفحة ${bookmark.page}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await ReadingPositionManager.removeBookmark(
                                bookmark.page);
                            Navigator.pop(context);
                            _showBookmarks(); // إعادة تحميل القائمة
                          },
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToPage(bookmark.page);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('خطأ في عرض العلامات المرجعية: $e');
    }
  }

  void _showHistory() async {
    try {
      final history = await ReadingPositionManager.getReadingHistory();
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) => Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تاريخ القراءة',
                style: _withSelectedFont(AppTypography.h6Arabic.copyWith(
                  fontWeight: FontWeight.bold,
                )),
              ),
              SizedBox(height: 20.h),
              if (history.isEmpty)
                Text(
                  'لا يوجد تاريخ قراءة',
                  style:
                      _withSelectedFont(AppTypography.bodyMediumArabic.copyWith(
                    color: Colors.grey,
                  )),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: history.take(10).length, // أظهر آخر 10 صفحات فقط
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      final timeAgo = _getTimeAgo(entry.timestamp);
                      return ListTile(
                        leading: const Icon(Icons.history, color: Colors.brown),
                        title: Text('الصفحة ${entry.page}'),
                        subtitle: Text(timeAgo),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToPage(entry.page);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('خطأ في عرض التاريخ: $e');
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  void _showSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MushafSettingsScreen(),
      ),
    );

    // إعادة تحميل الإعدادات بعد العودة من شاشة الإعدادات
    if (result != null || mounted) {
      await _loadSettings();
    }
  }

  // Helper to apply selected font family using GoogleFonts if available
  TextStyle _withSelectedFont(TextStyle base) {
    final font = settings?.fontFamily;
    if (font == null || font.isEmpty) return base;
    try {
      // Resolve the actual fontFamily name and apply it to the base
      // TextStyle. This is more robust when AppTypography already
      // embeds a concrete font family.
      String? resolvedFamily;
      switch (font) {
        case 'Amiri':
          resolvedFamily = GoogleFonts.amiri().fontFamily;
          break;
        case 'Cairo':
          resolvedFamily = GoogleFonts.cairo().fontFamily;
          break;
        case 'Tajawal':
          resolvedFamily = GoogleFonts.tajawal().fontFamily;
          break;
        case 'NotoNaskhArabic':
          resolvedFamily = GoogleFonts.notoNaskhArabic().fontFamily;
          break;
        case 'Scheherazade':
          resolvedFamily =
              GoogleFonts.getFont('Scheherazade').fontFamily ?? 'Scheherazade';
          break;
        default:
          resolvedFamily = GoogleFonts.getFont(font).fontFamily ?? font;
      }

      if (resolvedFamily!.isNotEmpty) {
        return base.copyWith(fontFamily: resolvedFamily);
      }
    } catch (_) {
      // Fallback: return base if GoogleFonts cannot load the font
      return base;
    }
    // If resolution failed, return base
    return base;
  }
}

/// نموذج بيانات محسن لصفحة القرآن
class QuranPageData {
  final int pageNumber;
  final List<Ayahs> ayahs;
  final String? surahInfo;
  final int? mainSurahNumber; // السورة الرئيسية في هذه الصفحة
  final bool isFirstPageOfSurah; // لتحديد إذا كانت أول صفحة في السورة

  QuranPageData({
    required this.pageNumber,
    required this.ayahs,
    this.surahInfo,
    this.mainSurahNumber,
    this.isFirstPageOfSurah = false,
  });
}
