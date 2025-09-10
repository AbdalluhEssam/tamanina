// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:quran_sharif/quran_sharif.dart';
// import '../../../../core/theme/app_typography.dart';

// /// شاشة المصحف الشريف - تصميم كلاسيكي مع الصفحات اليمين واليسار
// class MushafPageScreen extends StatefulWidget {
//   final int initialPage;

//   const MushafPageScreen({
//     super.key,
//     this.initialPage = 1,
//   });

//   @override
//   State<MushafPageScreen> createState() => _MushafPageScreenState();
// }

// class _MushafPageScreenState extends State<MushafPageScreen>
//     with TickerProviderStateMixin {
//   late PageController _pageController;
//   late AnimationController _fadeController;
//   late AnimationController _scaleController;

//   int currentPage = 1;
//   bool isLoading = true;
//   List<QuranPage> quranPages = [];

//   final int totalPages = 604; // إجمالي صفحات المصحف

//   @override
//   void initState() {
//     super.initState();
//     currentPage = widget.initialPage;
//     _setupAnimations();
//     _setupPageController();
//     _loadQuranData();
//     _loadSavedPage();
//   }

//   void _setupAnimations() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _scaleController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//   }

//   void _setupPageController() {
//     // نبدأ بالصفحة الفردية (اليمين) لأن التخطيط عربي
//     int initialPageIndex = ((currentPage - 1) ~/ 2);
//     _pageController = PageController(initialPage: initialPageIndex);
//   }

//   Future<void> _loadSavedPage() async {
//     // يمكن إضافة dependency injection هنا لاحقاً
//     // final localDataSource = GetIt.instance<QuranLocalDataSource>();
//     // final savedPage = await localDataSource.getCurrentPage();
//     // if (savedPage != currentPage) {
//     //   setState(() {
//     //     currentPage = savedPage;
//     //   });
//     //   _pageController.jumpToPage((currentPage - 1) ~/ 2);
//     // }
//   }

//   Future<void> _saveCurrentPage() async {
//     // يمكن إضافة dependency injection هنا لاحقاً
//     // final localDataSource = GetIt.instance<QuranLocalDataSource>();
//     // await localDataSource.saveCurrentPage(currentPage);
//   }

//   Future<void> _loadQuranData() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });

//       // تحميل صفحات القرآن من مكتبة quran_sharif
//       quranPages = await _buildQuranPages();

//       setState(() {
//         isLoading = false;
//       });

//       _fadeController.forward();
//     } catch (e) {
//       print('خطأ في تحميل بيانات القرآن: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<List<QuranPage>> _buildQuranPages() async {
//     List<QuranPage> pages = [];

//     // تحميل جميع السور
//     final surahs = Quran.getAllSurah();

//     // توزيع الآيات على الصفحات حسب ترتيب المصحف
//     int currentPageNum = 1;
//     List<String> currentPageVerses = [];

//     for (final surah in surahs) {
//       for (final ayah in surah.ayahs) {
//         // إضافة الآية للصفحة الحالية
//         String verseText = ayah.text;
//         if (ayah.numberInSurah == 1 && surah.number != 1 && surah.number != 9) {
//           // إضافة البسملة في بداية السور (عدا الفاتحة والتوبة)
//           verseText = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ $verseText';
//         }

//         currentPageVerses.add(verseText);

//         // محاكاة توزيع الآيات على الصفحات
//         // (في التطبيق الحقيقي، سيكون لديك ملف يحدد أي آية في أي صفحة)
//         if (currentPageVerses.length >= 10 || // عدد تقريبي للآيات في الصفحة
//             (surah.number == surahs.last.number &&
//                 ayah.numberInSurah == surah.ayahs.last.numberInSurah)) {
//           pages.add(QuranPage(
//             pageNumber: currentPageNum,
//             verses: List.from(currentPageVerses),
//             surahInfo: _getSurahInfoForPage(surah),
//           ));

//           currentPageVerses.clear();
//           currentPageNum++;

//           if (currentPageNum > totalPages) break;
//         }
//       }
//       if (currentPageNum > totalPages) break;
//     }

//     return pages;
//   }

//   String _getSurahInfoForPage(Surahs surah) {
//     return 'سورة ${surah.name} - ${surah.revelationType == "Meccan" ? "مكية" : "مدنية"}';
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _fadeController.dispose();
//     _scaleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5DC), // لون ورقي كلاسيكي
//       appBar: _buildAppBar(),
//       body: isLoading ? _buildLoadingState() : _buildMushafPages(),
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios, color: Colors.brown),
//         onPressed: () => Navigator.pop(context),
//       ),
//       title: Text(
//         'المصحف الشريف',
//         style: AppTypography.h6Arabic.copyWith(
//           color: Colors.brown,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       centerTitle: true,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.bookmark_border, color: Colors.brown),
//           onPressed: _showBookmarks,
//         ),
//         IconButton(
//           icon: const Icon(Icons.settings, color: Colors.brown),
//           onPressed: _showSettings,
//         ),
//       ],
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             color: Colors.brown,
//             strokeWidth: 3.w,
//           ),
//           SizedBox(height: 20.h),
//           Text(
//             'جارٍ تحميل المصحف الشريف...',
//             style: AppTypography.bodyLargeArabic.copyWith(
//               color: Colors.brown,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMushafPages() {
//     return FadeTransition(
//       opacity: _fadeController,
//       child: PageView.builder(
//         controller: _pageController,
//         onPageChanged: _onPageChanged,
//         itemCount: (totalPages / 2).ceil(),
//         itemBuilder: (context, index) {
//           return _buildDoublePage(index);
//         },
//       ),
//     );
//   }

//   Widget _buildDoublePage(int index) {
//     final leftPageNumber = index * 2 + 1; // الصفحة اليسرى (فردية)
//     final rightPageNumber = index * 2 + 2; // الصفحة اليمنى (زوجية)

//     return Container(
//       margin: EdgeInsets.all(8.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.brown.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // الصفحة اليسرى
//           Expanded(
//             child: _buildSinglePage(leftPageNumber, isLeft: true),
//           ),

//           // خط الفصل في المنتصف
//           Container(
//             width: 2.w,
//             color: Colors.brown.withOpacity(0.3),
//           ),

//           // الصفحة اليمنى
//           if (rightPageNumber <= totalPages)
//             Expanded(
//               child: _buildSinglePage(rightPageNumber, isLeft: false),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSinglePage(int pageNumber, {required bool isLeft}) {
//     if (pageNumber > quranPages.length) {
//       return Container(); // صفحة فارغة
//     }

//     final page = quranPages[pageNumber - 1];

//     return Container(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // رأس الصفحة
//           _buildPageHeader(page, isLeft),

//           SizedBox(height: 16.h),

//           // محتوى الصفحة
//           Expanded(
//             child: _buildPageContent(page),
//           ),

//           SizedBox(height: 16.h),

//           // تذييل الصفحة
//           _buildPageFooter(pageNumber),
//         ],
//       ),
//     );
//   }

//   Widget _buildPageHeader(QuranPage page, bool isLeft) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.brown.withOpacity(0.3)),
//         borderRadius: BorderRadius.circular(8.r),
//       ),
//       child: Text(
//         page.surahInfo,
//         textAlign: TextAlign.center,
//         style: AppTypography.captionArabic.copyWith(
//           color: Colors.brown,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   Widget _buildPageContent(QuranPage page) {
//     return SingleChildScrollView(
//       child: Column(
//         children: page.verses.asMap().entries.map((entry) {
//           return Padding(
//             padding: EdgeInsets.symmetric(vertical: 4.h),
//             child: Text(
//               entry.value,
//               textAlign: TextAlign.justify,
//               style: AppTypography.bodyLargeArabic.copyWith(
//                 fontSize: 18.sp,
//                 height: 2.0,
//                 color: Colors.black87,
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildPageFooter(int pageNumber) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // رقم الصفحة
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//             decoration: BoxDecoration(
//               color: Colors.brown.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(15.r),
//             ),
//             child: Text(
//               pageNumber.toString(),
//               style: AppTypography.captionArabic.copyWith(
//                 color: Colors.brown,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           // أيقونات التفاعل
//           Row(
//             children: [
//               IconButton(
//                 icon: Icon(
//                   Icons.bookmark_border,
//                   size: 20.w,
//                   color: Colors.brown,
//                 ),
//                 onPressed: () => _togglePageBookmark(pageNumber),
//               ),
//               IconButton(
//                 icon: Icon(
//                   Icons.share,
//                   size: 20.w,
//                   color: Colors.brown,
//                 ),
//                 onPressed: () => _sharePage(pageNumber),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNavigationBar() {
//     return Container(
//       height: 70.h,
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             blurRadius: 5,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // زر الصفحة السابقة
//           IconButton(
//             onPressed: currentPage > 1 ? _goToPreviousPage : null,
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: currentPage > 1 ? Colors.brown : Colors.grey,
//             ),
//           ),

//           // مؤشر الصفحة الحالية
//           GestureDetector(
//             onTap: _showPageNavigator,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
//               decoration: BoxDecoration(
//                 color: Colors.brown.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20.r),
//                 border: Border.all(color: Colors.brown.withOpacity(0.3)),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     '$currentPage',
//                     style: AppTypography.bodyLargeArabic.copyWith(
//                       color: Colors.brown,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(width: 5.w),
//                   Text(
//                     'من',
//                     style: AppTypography.captionArabic.copyWith(
//                       color: Colors.brown,
//                     ),
//                   ),
//                   SizedBox(width: 5.w),
//                   Text(
//                     '$totalPages',
//                     style: AppTypography.captionArabic.copyWith(
//                       color: Colors.brown,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // زر الصفحة التالية
//           IconButton(
//             onPressed: currentPage < totalPages ? _goToNextPage : null,
//             icon: Icon(
//               Icons.arrow_forward_ios,
//               color: currentPage < totalPages ? Colors.brown : Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _onPageChanged(int pageIndex) {
//     final newPage = pageIndex * 2 + 1;
//     setState(() {
//       currentPage = newPage;
//     });
//     _saveCurrentPage();
//   }

//   void _goToPreviousPage() {
//     if (currentPage > 1) {
//       final newPageIndex = ((currentPage - 3) ~/ 2);
//       _pageController.animateToPage(
//         newPageIndex,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void _goToNextPage() {
//     if (currentPage < totalPages) {
//       final newPageIndex = ((currentPage + 1) ~/ 2);
//       _pageController.animateToPage(
//         newPageIndex,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void _showPageNavigator() {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (context) => _buildPageNavigatorSheet(),
//     );
//   }

//   Widget _buildPageNavigatorSheet() {
//     final TextEditingController controller = TextEditingController();

//     return Container(
//       padding: EdgeInsets.all(20.w),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'انتقل إلى صفحة',
//             style: AppTypography.h6Arabic.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 20.h),
//           TextField(
//             controller: controller,
//             keyboardType: TextInputType.number,
//             textAlign: TextAlign.center,
//             decoration: InputDecoration(
//               hintText: 'رقم الصفحة (1-$totalPages)',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10.r),
//               ),
//             ),
//           ),
//           SizedBox(height: 20.h),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey,
//                   ),
//                   child: const Text('إلغاء'),
//                 ),
//               ),
//               SizedBox(width: 10.w),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     final pageNum = int.tryParse(controller.text);
//                     if (pageNum != null &&
//                         pageNum >= 1 &&
//                         pageNum <= totalPages) {
//                       _navigateToPage(pageNum);
//                       Navigator.pop(context);
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.brown,
//                   ),
//                   child: const Text('انتقال'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateToPage(int pageNumber) {
//     setState(() {
//       currentPage = pageNumber;
//     });
//     final pageIndex = ((pageNumber - 1) ~/ 2);
//     _pageController.animateToPage(
//       pageIndex,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//     _saveCurrentPage();
//   }

//   void _togglePageBookmark(int pageNumber) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('تم حفظ الصفحة $pageNumber كعلامة مرجعية'),
//         backgroundColor: Colors.brown,
//       ),
//     );
//   }

//   void _sharePage(int pageNumber) {
//     // تنفيذ مشاركة الصفحة
//   }

//   void _showBookmarks() {
//     // عرض العلامات المرجعية
//   }

//   void _showSettings() {
//     // عرض إعدادات المصحف
//   }
// }

// /// نموذج بيانات صفحة القرآن
// class QuranPage {
//   final int pageNumber;
//   final List<String> verses;
//   final String surahInfo;

//   QuranPage({
//     required this.pageNumber,
//     required this.verses,
//     required this.surahInfo,
//   });
// }
