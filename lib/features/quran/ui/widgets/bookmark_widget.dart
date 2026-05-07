import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';

/// ويجت العلامة المرجعية المحسّن
class BookmarkWidget extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback onToggle;
  final String? title;
  final String? subtitle;
  final Color color;

  const BookmarkWidget({
    super.key,
    required this.isBookmarked,
    required this.onToggle,
    this.title,
    this.subtitle,
    this.color = AppColors.goldAccent,
  });

  @override
  State<BookmarkWidget> createState() => _BookmarkWidgetState();
}

class _BookmarkWidgetState extends State<BookmarkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onToggle();
    if (widget.isBookmarked) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: widget.isBookmarked
                      ? LinearGradient(
                          colors: [
                            widget.color,
                            widget.color.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            Colors.grey.shade300,
                            Colors.grey.shade400,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: widget.isBookmarked
                      ? [
                          BoxShadow(
                            color: widget.color.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: widget.isBookmarked
                          ? Colors.white
                          : Colors.grey.shade600,
                      size: 24.w,
                    ),
                    if (widget.title != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        widget.title!,
                        style: AppTypography.captionArabic.copyWith(
                          color: widget.isBookmarked
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (widget.subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        widget.subtitle!,
                        style: AppTypography.captionArabic.copyWith(
                          color: widget.isBookmarked
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey.shade500,
                          fontSize: 10.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ويجت لإدارة العلامات المرجعية المتقدمة
class AdvancedBookmarkManager extends StatefulWidget {
  final List<BookmarkData> bookmarks;
  final Function(BookmarkData) onBookmarkSelected;
  final Function(BookmarkData) onBookmarkDeleted;
  final Function(BookmarkData) onBookmarkEdited;

  const AdvancedBookmarkManager({
    super.key,
    required this.bookmarks,
    required this.onBookmarkSelected,
    required this.onBookmarkDeleted,
    required this.onBookmarkEdited,
  });

  @override
  State<AdvancedBookmarkManager> createState() =>
      _AdvancedBookmarkManagerState();
}

class _AdvancedBookmarkManagerState extends State<AdvancedBookmarkManager>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  List<BookmarkData> get filteredBookmarks {
    if (searchQuery.isEmpty) return widget.bookmarks;
    return widget.bookmarks
        .where((bookmark) =>
            bookmark.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            bookmark.description
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildBookmarkCategories(),
              Expanded(child: _buildBookmarksList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 24.w,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'العلامات المرجعية',
            style: AppTypography.h5Arabic.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.goldAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.goldAccent),
            ),
            child: Text(
              '${widget.bookmarks.length}',
              style: AppTypography.captionArabic.copyWith(
                color: AppColors.goldAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        style: AppTypography.bodyMediumArabic.copyWith(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'البحث في العلامات المرجعية...',
          hintStyle: AppTypography.bodyMediumArabic.copyWith(
            color: Colors.white.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.8),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkCategories() {
    final categories = ['الكل', 'الآيات', 'السور', 'الصفحات'];

    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == 0; // مؤقتاً

          return Container(
            margin: EdgeInsets.only(left: 8.w),
            child: FilterChip(
              label: Text(
                category,
                style: AppTypography.captionArabic.copyWith(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              backgroundColor: Colors.white.withOpacity(0.1),
              selectedColor: AppColors.goldAccent,
              side: BorderSide(
                color: isSelected
                    ? AppColors.goldAccent
                    : Colors.white.withOpacity(0.3),
              ),
              onSelected: (selected) {
                // تنفيذ منطق الفلترة
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookmarksList() {
    if (filteredBookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64.w,
              color: Colors.white.withOpacity(0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              searchQuery.isEmpty
                  ? 'لا توجد علامات مرجعية'
                  : 'لم يتم العثور على نتائج',
              style: AppTypography.bodyLargeArabic.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: filteredBookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = filteredBookmarks[index];
        return _buildBookmarkItem(bookmark, index);
      },
    );
  }

  Widget _buildBookmarkItem(BookmarkData bookmark, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () => widget.onBookmarkSelected(bookmark),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        bookmark.color,
                        bookmark.color.withOpacity(0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      bookmark.icon,
                      color: Colors.white,
                      size: 24.w,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookmark.title,
                        style: AppTypography.bodyLargeArabic.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        bookmark.description,
                        style: AppTypography.captionArabic.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14.w,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            bookmark.dateAdded,
                            style: AppTypography.captionArabic.copyWith(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        widget.onBookmarkEdited(bookmark);
                        break;
                      case 'delete':
                        widget.onBookmarkDeleted(bookmark);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18.w),
                          SizedBox(width: 8.w),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18.w, color: Colors.red),
                          SizedBox(width: 8.w),
                          Text('حذف', style: TextStyle(color: Colors.red)),
                        ],
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

/// نموذج بيانات العلامة المرجعية
class BookmarkData {
  final String id;
  final String title;
  final String description;
  final int pageNumber;
  final int? surahNumber;
  final int? verseNumber;
  final Color color;
  final IconData icon;
  final String dateAdded;
  final String? notes;
  final List<String> tags;

  BookmarkData({
    required this.id,
    required this.title,
    required this.description,
    required this.pageNumber,
    this.surahNumber,
    this.verseNumber,
    this.color = AppColors.goldAccent,
    this.icon = Icons.bookmark,
    required this.dateAdded,
    this.notes,
    this.tags = const [],
  });

  BookmarkData copyWith({
    String? id,
    String? title,
    String? description,
    int? pageNumber,
    int? surahNumber,
    int? verseNumber,
    Color? color,
    IconData? icon,
    String? dateAdded,
    String? notes,
    List<String>? tags,
  }) {
    return BookmarkData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pageNumber: pageNumber ?? this.pageNumber,
      surahNumber: surahNumber ?? this.surahNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      dateAdded: dateAdded ?? this.dateAdded,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }
}

/// ويجت العلامة السريعة
class QuickBookmarkWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickBookmarkWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: color.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 16.w,
              ),
              SizedBox(width: 6.w),
              Text(
                title,
                style: AppTypography.captionArabic.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
