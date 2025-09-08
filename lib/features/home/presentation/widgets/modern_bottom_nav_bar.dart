import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Modern Glass-Effect Bottom Navigation Bar
class ModernBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<ModernBottomNavBar> createState() => _ModernBottomNavBarState();
}

class _ModernBottomNavBarState extends State<ModernBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _indicatorAnimation;

  final List<BottomNavItem> _items = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'الرئيسية',
      englishLabel: 'Home',
    ),
    BottomNavItem(
      icon: Icons.book_outlined,
      activeIcon: Icons.book_rounded,
      label: 'القرآن',
      englishLabel: 'Quran',
    ),
    BottomNavItem(
      icon: Icons.radio_button_unchecked_outlined,
      activeIcon: Icons.radio_button_checked_rounded,
      label: 'التسبيح',
      englishLabel: 'Tasbeeh',
    ),
    BottomNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'الإعدادات',
      englishLabel: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDuration.normal,
      vsync: this,
    );

    _indicatorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.gentle,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 70.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: AppColors.goldAccent.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length, (index) {
              return _buildNavItem(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _items[index];
    final isActive = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onTap(index);
          _animationController.reset();
          _animationController.forward();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container with Background
              AnimatedContainer(
                duration: AppDuration.fast,
                width: isActive ? 36.w : 32.w,
                height: isActive ? 36.w : 32.w,
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(
                          colors: [
                            AppColors.primaryGreen.withOpacity(0.2),
                            AppColors.goldAccent.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(18.r),
                  border: isActive
                      ? Border.all(
                          color: AppColors.goldAccent.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: AppDuration.fast,
                    child: Icon(
                      isActive ? item.activeIcon : item.icon,
                      key: ValueKey(isActive),
                      color: isActive
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
                      size: isActive ? 20.w : 18.w,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // Label
              AnimatedDefaultTextStyle(
                duration: AppDuration.fast,
                style: TextStyle(
                  color: isActive
                      ? AppColors.primaryGreen
                      : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: isActive ? 10.sp : 9.sp,
                  fontFamily: 'Cairo',
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Active Indicator
              if (isActive)
                AnimatedBuilder(
                  animation: _indicatorAnimation,
                  builder: (context, child) {
                    return Container(
                      margin: EdgeInsets.only(top: 2.h),
                      width: 16.w * _indicatorAnimation.value,
                      height: 2.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.goldAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1.r),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String englishLabel;

  BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.englishLabel,
  });
}
