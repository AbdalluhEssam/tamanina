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
import 'surah_details_screen.dart';

class QuranIndexScreen extends StatefulWidget {
  const QuranIndexScreen({super.key});

  @override
  State<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends State<QuranIndexScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<QuranEntity> _allSurahs = [];
  List<QuranEntity> _filteredSurahs = [];

  @override
  void initState() {
    super.initState();
    context.read<QuranBloc>().add(LoadAllSurahs());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSurahs = _allSurahs.where((surah) {
        return surah.surahNameArabic.toLowerCase().contains(query) ||
            surah.surahNameEnglish.toLowerCase().contains(query) ||
            surah.surahNumber.toString().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchSection(),
          _buildQuickFilters(),
          Expanded(
            child: BlocConsumer<QuranBloc, QuranState>(
              listener: (context, state) {
                if (state is SurahsLoaded) {
                  _allSurahs = state.surahs;
                  _filteredSurahs = state.surahs;
                }
              },
              builder: (context, state) {
                if (state is QuranLoading) {
                  return _buildLoadingState();
                } else if (state is SurahsLoaded ||
                    _filteredSurahs.isNotEmpty) {
                  return _buildSurahsList();
                } else if (state is QuranError) {
                  return _buildErrorState(state.message);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
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
        'فهرس السور',
        style: AppTypography.h6Arabic.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: AppSpacing.paddingMD,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ابحث عن سورة...',
          hintStyle: AppTypography.bodyMediumArabic.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primaryGreen,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: AppRadius.md,
            borderSide: BorderSide(
              color: AppColors.primaryGreen.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.md,
            borderSide: BorderSide(
              color: AppColors.primaryGreen.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.md,
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('الكل', () {
            setState(() {
              _filteredSurahs = _allSurahs;
            });
            _searchController.clear();
          }),
          _buildFilterChip('المكية', () {
            setState(() {
              _filteredSurahs = _allSurahs.where((s) => s.isMakki).toList();
            });
          }),
          _buildFilterChip('المدنية', () {
            setState(() {
              _filteredSurahs = _allSurahs.where((s) => s.isMadani).toList();
            });
          }),
          _buildFilterChip('المفضلة', () {
            setState(() {
              _filteredSurahs = _allSurahs.where((s) => s.isFavorite).toList();
            });
          }),
          _buildFilterChip('قيد القراءة', () {
            setState(() {
              _filteredSurahs =
                  _allSurahs.where((s) => s.lastReadVerse > 0).toList();
            });
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        label: Text(
          label,
          style: AppTypography.labelSmallArabic.copyWith(
            color: AppColors.primaryGreen,
          ),
        ),
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primaryGreen.withOpacity(0.1),
        side: BorderSide(
          color: AppColors.primaryGreen.withOpacity(0.3),
        ),
      ),
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
              context.read<QuranBloc>().add(LoadAllSurahs());
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

  Widget _buildSurahsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: _filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = _filteredSurahs[index];
        return _buildSurahItem(surah);
      },
    );
  }

  Widget _buildSurahItem(QuranEntity surah) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.md,
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<QuranBloc>(),
                  child: SurahDetailsScreen(
                    surahNumber: surah.surahNumber,
                    surahName: surah.surahNameArabic,
                  ),
                ),
              ),
            );
          },
          borderRadius: AppRadius.md,
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: Row(
              children: [
                // Surah number
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: AppRadius.sm,
                  ),
                  child: Center(
                    child: Text(
                      '${surah.surahNumber}',
                      style: AppTypography.labelLargeArabic.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                AppSpacing.horizontalSpaceMD,

                // Surah info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.surahNameArabic,
                        style: AppTypography.bodyLargeArabic.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.verticalSpaceXS,
                      Text(
                        surah.surahNameEnglish,
                        style: AppTypography.captionArabic.copyWith(
                          color: AppColors.textSecondary,
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

                      // Reading progress
                      if (surah.lastReadVerse > 0) ...[
                        AppSpacing.verticalSpaceXS,
                        Row(
                          children: [
                            Icon(
                              Icons.bookmark,
                              size: 14.w,
                              color: AppColors.goldAccent,
                            ),
                            AppSpacing.horizontalSpaceXS,
                            Text(
                              'آخر قراءة: ${surah.lastReadVerse}',
                              style: AppTypography.captionArabic.copyWith(
                                color: AppColors.goldAccent,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.verticalSpaceXS,
                        LinearProgressIndicator(
                          value: surah.readingProgress,
                          backgroundColor: AppColors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryGreen,
                          ),
                          minHeight: 2.h,
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        context
                            .read<QuranBloc>()
                            .add(ToggleSurahFavorite(surah.surahNumber));
                      },
                      icon: Icon(
                        surah.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: surah.isFavorite
                            ? AppColors.error
                            : AppColors.textSecondary,
                        size: 20.w,
                      ),
                    ),

                    // Revelation type badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: surah.isMakki
                            ? AppColors.goldAccent.withOpacity(0.1)
                            : AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: AppRadius.xs,
                      ),
                      child: Text(
                        surah.isMakki ? 'مكية' : 'مدنية',
                        style: AppTypography.captionArabic.copyWith(
                          color: surah.isMakki
                              ? AppColors.goldAccent
                              : AppColors.primaryBlue,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
