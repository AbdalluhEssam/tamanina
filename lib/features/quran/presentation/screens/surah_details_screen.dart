import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../domain/entities/quran_entity.dart';
import '../bloc/quran_bloc.dart';
import '../bloc/quran_event.dart';
import '../bloc/quran_state.dart';

class SurahDetailsScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailsScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahDetailsScreen> createState() => _SurahDetailsScreenState();
}

class _SurahDetailsScreenState extends State<SurahDetailsScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<QuranBloc>().add(LoadSurah(widget.surahNumber));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: BlocBuilder<QuranBloc, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return _buildLoadingState();
          } else if (state is SurahLoaded) {
            return _buildSurahContent(state.surah);
          } else if (state is QuranError) {
            return _buildErrorState(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        widget.surahName,
        style: AppTypography.h6Arabic.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Navigate to search
          },
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border),
          onPressed: () {
            // Show bookmarks
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryGreen,
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.w,
            color: AppColors.error,
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            'حدث خطأ',
            style: AppTypography.h6Arabic.copyWith(
              color: AppColors.error,
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            message,
            style: AppTypography.bodyMediumArabic.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceMD,
          ElevatedButton(
            onPressed: () {
              context.read<QuranBloc>().add(LoadSurah(widget.surahNumber));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'إعادة المحاولة',
              style: AppTypography.labelMediumArabic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahContent(QuranEntity surah) {
    return Column(
      children: [
        _buildSurahHeader(surah),
        Expanded(
          child: _buildVersesList(surah),
        ),
        _buildBottomBar(surah),
      ],
    );
  }

  Widget _buildSurahHeader(QuranEntity surah) {
    return Container(
      margin: AppSpacing.paddingMD,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withOpacity(0.1),
            AppColors.goldAccent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: AppColors.goldAccent.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Basmala (except for At-Tawbah)
          if (surah.surahNumber != 9) _buildBasmala(),

          // Surah info
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: AppRadius.md,
                ),
                child: Center(
                  child: Text(
                    '${surah.surahNumber}',
                    style: AppTypography.h6Arabic.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              AppSpacing.horizontalSpaceMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.surahNameArabic,
                      style: AppTypography.h5Arabic.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.verticalSpaceXS,
                    Row(
                      children: [
                        Text(
                          '${surah.totalVerses} آية',
                          style: AppTypography.captionArabic.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: AppTypography.captionArabic.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          surah.revelationType,
                          style: AppTypography.captionArabic.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  context
                      .read<QuranBloc>()
                      .add(ToggleSurahFavorite(surah.surahNumber));
                },
                icon: Icon(
                  surah.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: surah.isFavorite
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasmala() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        style: AppTypography.h5Arabic.copyWith(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVersesList(QuranEntity surah) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: surah.verses.length,
      itemBuilder: (context, index) {
        final verse = surah.verses[index];
        return _buildVerseItem(verse);
      },
    );
  }

  Widget _buildVerseItem(VerseEntity verse) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.md,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verse text
          Text(
            verse.arabicText,
            style: AppTypography.bodyLargeArabic.copyWith(
              color: AppColors.textPrimary,
              height: 1.8,
              fontSize: 20.sp,
            ),
            textAlign: TextAlign.right,
          ),

          AppSpacing.verticalSpaceMD,

          // Verse actions
          Row(
            children: [
              // Verse number
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: AppRadius.sm,
                ),
                child: Text(
                  '${verse.verseNumber}',
                  style: AppTypography.captionArabic.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              // Actions
              IconButton(
                onPressed: () {
                  context.read<QuranBloc>().add(ToggleVerseFavorite(
                        verse.surahNumber,
                        verse.verseNumber,
                      ));
                },
                icon: Icon(
                  verse.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: verse.isFavorite
                      ? AppColors.error
                      : AppColors.textSecondary,
                  size: 20.w,
                ),
              ),

              IconButton(
                onPressed: () {
                  context.read<QuranBloc>().add(ToggleVerseBookmark(
                        verse.surahNumber,
                        verse.verseNumber,
                      ));
                },
                icon: Icon(
                  verse.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: verse.isBookmarked
                      ? AppColors.goldAccent
                      : AppColors.textSecondary,
                  size: 20.w,
                ),
              ),

              IconButton(
                onPressed: () {
                  _showVerseOptionsDialog(verse);
                },
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                  size: 20.w,
                ),
              ),
            ],
          ),

          // Show personal note if exists
          if (verse.personalNote != null && verse.personalNote!.isNotEmpty) ...[
            AppSpacing.verticalSpaceSM,
            Container(
              padding: AppSpacing.paddingSM,
              decoration: BoxDecoration(
                color: AppColors.goldAccent.withOpacity(0.1),
                borderRadius: AppRadius.sm,
              ),
              child: Text(
                verse.personalNote!,
                style: AppTypography.captionArabic.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],

          // Show tags if exist
          if (verse.tags.isNotEmpty) ...[
            AppSpacing.verticalSpaceSM,
            Wrap(
              spacing: 8.w,
              children: verse.tags
                  .map((tag) => Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: AppRadius.xs,
                        ),
                        child: Text(
                          tag,
                          style: AppTypography.captionArabic.copyWith(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(QuranEntity surah) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Surah
          if (widget.surahNumber > 1)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: context.read<QuranBloc>(),
                        child: SurahDetailsScreen(
                          surahNumber: widget.surahNumber - 1,
                          surahName: 'السورة السابقة',
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_back_ios),
                label: const Text('السابقة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: AppColors.primaryGreen,
                ),
              ),
            ),

          if (widget.surahNumber > 1 && widget.surahNumber < 114)
            AppSpacing.horizontalSpaceMD,

          // Next Surah
          if (widget.surahNumber < 114)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: context.read<QuranBloc>(),
                        child: SurahDetailsScreen(
                          surahNumber: widget.surahNumber + 1,
                          surahName: 'السورة التالية',
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios),
                label: const Text('التالية'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showVerseOptionsDialog(VerseEntity verse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'خيارات الآية ${verse.verseNumber}',
          style: AppTypography.h6Arabic,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('نسخ'),
              onTap: () {
                // Copy verse
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('مشاركة'),
              onTap: () {
                // Share verse
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('إضافة ملاحظة'),
              onTap: () {
                Navigator.pop(context);
                _showAddNoteDialog(verse);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(VerseEntity verse) {
    final noteController =
        TextEditingController(text: verse.personalNote ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إضافة ملاحظة',
          style: AppTypography.h6Arabic,
        ),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'اكتب ملاحظتك هنا...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<QuranBloc>().add(AddVerseNote(
                    verse.surahNumber,
                    verse.verseNumber,
                    noteController.text,
                  ));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
