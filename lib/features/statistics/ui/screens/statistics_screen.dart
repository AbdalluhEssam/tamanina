import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// شاشة الإحصائيات
/// Statistics Screen - Shows user's worship statistics
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Box _statsBox;

  // Statistics data
  int _totalTasbeeh = 0;
  int _totalAzkar = 0;
  int _totalQuranPages = 0;
  int _prayersOnTime = 0;
  int _streakDays = 0;
  List<DailyStats> _weeklyStats = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      _statsBox = await Hive.openBox('statistics');

      setState(() {
        _totalTasbeeh = _statsBox.get('total_tasbeeh', defaultValue: 0);
        _totalAzkar = _statsBox.get('total_azkar', defaultValue: 0);
        _totalQuranPages = _statsBox.get('total_quran_pages', defaultValue: 0);
        _prayersOnTime = _statsBox.get('prayers_on_time', defaultValue: 0);
        _streakDays = _statsBox.get('streak_days', defaultValue: 0);

        // Load weekly stats
        final weekData =
            _statsBox.get('weekly_stats', defaultValue: <dynamic>[]);
        _weeklyStats =
            (weekData as List).map((e) => DailyStats.fromMap(e)).toList();

        // Generate sample data if empty
        if (_weeklyStats.isEmpty) {
          _weeklyStats = _generateSampleWeeklyStats();
        }
      });
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  List<DailyStats> _generateSampleWeeklyStats() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DailyStats(
        date: date,
        tasbeehCount: 0,
        azkarCount: 0,
        quranPages: 0,
        prayersCompleted: 0,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'الإحصائيات',
          style: AppTypography.appBarTitle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'اليوم', icon: Icon(Icons.today_rounded)),
            Tab(text: 'الأسبوع', icon: Icon(Icons.calendar_view_week_rounded)),
            Tab(text: 'الإجمالي', icon: Icon(Icons.bar_chart_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(isDark),
          _buildWeeklyTab(isDark),
          _buildTotalTab(isDark),
        ],
      ),
    );
  }

  Widget _buildTodayTab(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak Card
          _buildStreakCard(isDark),
          SizedBox(height: 16.h),

          // Today's Summary
          Text(
            'ملخص اليوم',
            style: AppTypography.h6Arabic.copyWith(
              color:
                  isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard(
                icon: Icons.fingerprint,
                title: 'التسبيح',
                value: _totalTasbeeh.toString(),
                subtitle: 'تسبيحة',
                color: AppColors.primaryGreen,
                isDark: isDark,
              ),
              _buildStatCard(
                icon: Icons.auto_stories,
                title: 'الأذكار',
                value: _totalAzkar.toString(),
                subtitle: 'ذكر',
                color: AppColors.goldAccent,
                isDark: isDark,
              ),
              _buildStatCard(
                icon: Icons.menu_book,
                title: 'القرآن',
                value: _totalQuranPages.toString(),
                subtitle: 'صفحة',
                color: Colors.blue,
                isDark: isDark,
              ),
              _buildStatCard(
                icon: Icons.mosque,
                title: 'الصلوات',
                value: '$_prayersOnTime/5',
                subtitle: 'في وقتها',
                color: Colors.purple,
                isDark: isDark,
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Goals Section
          Text(
            'أهداف اليوم',
            style: AppTypography.h6Arabic.copyWith(
              color:
                  isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),

          _buildGoalProgress(
            title: 'التسبيح',
            current: _totalTasbeeh,
            goal: 100,
            color: AppColors.primaryGreen,
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _buildGoalProgress(
            title: 'أذكار الصباح والمساء',
            current: _totalAzkar,
            goal: 50,
            color: AppColors.goldAccent,
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _buildGoalProgress(
            title: 'قراءة القرآن',
            current: _totalQuranPages,
            goal: 5,
            color: Colors.blue,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات الأسبوع',
            style: AppTypography.h6Arabic.copyWith(
              color:
                  isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // Weekly Chart
          Container(
            height: 200.h,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildWeeklyChart(isDark),
          ),

          SizedBox(height: 24.h),

          // Daily breakdown
          Text(
            'تفاصيل الأيام',
            style: AppTypography.h6Arabic.copyWith(
              color:
                  isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),

          ..._weeklyStats.reversed
              .map((stats) => _buildDailyCard(stats, isDark)),
        ],
      ),
    );
  }

  Widget _buildTotalTab(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Stats Summary
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen,
                  AppColors.primaryGreen.withOpacity(0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                Icon(Icons.emoji_events_rounded,
                    color: Colors.white, size: 48.w),
                SizedBox(height: 12.h),
                Text(
                  'إجمالي العبادات',
                  style: AppTypography.h5Arabic.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'ما شاء الله! استمر في المواظبة',
                  style: AppTypography.bodySmallArabic.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Lifetime Stats
          _buildLifetimeStat(
            icon: Icons.fingerprint,
            title: 'إجمالي التسبيح',
            value: _totalTasbeeh.toString(),
            color: AppColors.primaryGreen,
            isDark: isDark,
          ),
          SizedBox(height: 12.h),
          _buildLifetimeStat(
            icon: Icons.auto_stories,
            title: 'إجمالي الأذكار',
            value: _totalAzkar.toString(),
            color: AppColors.goldAccent,
            isDark: isDark,
          ),
          SizedBox(height: 12.h),
          _buildLifetimeStat(
            icon: Icons.menu_book,
            title: 'صفحات القرآن',
            value: _totalQuranPages.toString(),
            color: Colors.blue,
            isDark: isDark,
          ),
          SizedBox(height: 12.h),
          _buildLifetimeStat(
            icon: Icons.local_fire_department,
            title: 'أيام متتالية',
            value: '$_streakDays يوم',
            color: Colors.orange,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 32.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سلسلة المواظبة',
                  style: AppTypography.bodyMediumArabic.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '$_streakDays يوم متتالي',
                  style: AppTypography.h5Arabic.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.trending_up,
            color: Colors.white,
            size: 28.w,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.w),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: AppTypography.bodySmallArabic.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.h4Arabic.copyWith(
                  color: isDark
                      ? AppColors.textOnSurfaceDark
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4.w),
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  subtitle,
                  style: AppTypography.bodySmallArabic.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgress({
    required String title,
    required int current,
    required int goal,
    required Color color,
    required bool isDark,
  }) {
    final progress = (current / goal).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodyMediumArabic.copyWith(
                  color: isDark
                      ? AppColors.textOnSurfaceDark
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                '$current / $goal',
                style: AppTypography.bodySmallArabic.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(bool isDark) {
    final days = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final value =
            index < _weeklyStats.length ? _weeklyStats[index].tasbeehCount : 0;
        final maxValue = 100.0;
        final height = ((value / maxValue) * 120).clamp(10.0, 120.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 24.w,
              height: height.h,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              days[index].substring(0, 2),
              style: AppTypography.bodySmallArabic.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.sp,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDailyCard(DailyStats stats, bool isDark) {
    final dayNames = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت'
    ];
    final dayName = dayNames[stats.date.weekday % 7];

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              dayName,
              style: AppTypography.bodySmallArabic.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(Icons.fingerprint, stats.tasbeehCount),
                _buildMiniStat(Icons.auto_stories, stats.azkarCount),
                _buildMiniStat(Icons.menu_book, stats.quranPages),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, int value) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: AppColors.textSecondary),
        SizedBox(width: 4.w),
        Text(
          value.toString(),
          style: AppTypography.bodySmallArabic.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLifetimeStat({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmallArabic.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.h5Arabic.copyWith(
                    color: isDark
                        ? AppColors.textOnSurfaceDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Daily statistics model
class DailyStats {
  final DateTime date;
  final int tasbeehCount;
  final int azkarCount;
  final int quranPages;
  final int prayersCompleted;

  DailyStats({
    required this.date,
    required this.tasbeehCount,
    required this.azkarCount,
    required this.quranPages,
    required this.prayersCompleted,
  });

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'tasbeehCount': tasbeehCount,
        'azkarCount': azkarCount,
        'quranPages': quranPages,
        'prayersCompleted': prayersCompleted,
      };

  factory DailyStats.fromMap(Map<dynamic, dynamic> map) => DailyStats(
        date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
        tasbeehCount: map['tasbeehCount'] ?? 0,
        azkarCount: map['azkarCount'] ?? 0,
        quranPages: map['quranPages'] ?? 0,
        prayersCompleted: map['prayersCompleted'] ?? 0,
      );
}
