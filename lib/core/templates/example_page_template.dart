import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';

/// Example Screen Template - MVVM Clean Architecture
/// Copy this template when creating new feature screens
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom AppBar with smooth scroll animation
            CustomAppBar(
              title: 'عنوان الصفحة',
              expandedHeight: 120,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Handle search action
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Handle more action
                  },
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: EdgeInsets.all(AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Your content widgets here
                  _buildHeader(),
                  AppSpacing.verticalSpaceLG,
                  _buildContentSection(),
                  AppSpacing.verticalSpaceLG,
                  _buildFooter(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: AppColors.goldAccent.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: AppColors.primaryGreen,
                size: AppSizing.iconLG,
              ),
              AppSpacing.horizontalSpaceMD,
              Expanded(
                child: Text(
                  'العنوان الرئيسي',
                  style: AppTypography.h5Arabic.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            'وصف قصير يشرح محتوى الصفحة',
            style: AppTypography.bodyMediumArabic.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'القسم الرئيسي',
          style: AppTypography.h6Arabic.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.verticalSpaceMD,
        // Add your content widgets
        Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            color: AppColors.creamAccent.withOpacity(0.3),
            borderRadius: AppRadius.md,
          ),
          child: Text(
            'محتوى الصفحة هنا',
            style: AppTypography.bodyLargeArabic,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: AppSpacing.paddingMD,
      child: Text(
        'تذييل الصفحة',
        style: AppTypography.captionArabic.copyWith(
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Example Screen with BLoC/Cubit State Management
class ExampleWithStatePage extends StatelessWidget {
  const ExampleWithStatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<ExampleCubit, ExampleState>(
          builder: (context, state) {
            if (state is ExampleLoading) {
              return _buildLoadingState();
            } else if (state is ExampleLoaded) {
              return _buildLoadedState(state);
            } else if (state is ExampleError) {
              return _buildErrorState(state.message);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        CustomAppBar(
          title: 'جاري التحميل...',
          expandedHeight: 100,
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
                AppSpacing.verticalSpaceMD,
                Text(
                  'جاري تحميل البيانات...',
                  style: AppTypography.bodyMediumArabic.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedState(ExampleLoaded state) {
    return CustomScrollView(
      slivers: [
        CustomAppBar(
          title: 'تم التحميل',
          expandedHeight: 120,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Refresh data
              },
            ),
          ],
        ),
        SliverPadding(
          padding: EdgeInsets.all(AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: AppSpacing.md),
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: AppColors.primaryGreen,
                    ),
                    title: Text(
                      'عنصر ${index + 1}',
                      style: AppTypography.bodyLargeArabic,
                    ),
                    subtitle: Text(
                      'تفاصيل العنصر',
                      style: AppTypography.bodyMediumArabic.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
              childCount: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return CustomScrollView(
      slivers: [
        CustomAppBar(
          title: 'خطأ',
          expandedHeight: 100,
        ),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: AppSpacing.screenPaddingAll,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.w,
                    color: AppColors.error,
                  ),
                  AppSpacing.verticalSpaceLG,
                  Text(
                    'حدث خطأ',
                    style: AppTypography.h5Arabic,
                  ),
                  AppSpacing.verticalSpaceMD,
                  Text(
                    message,
                    style: AppTypography.bodyMediumArabic.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalSpaceXL,
                  ElevatedButton(
                    onPressed: () {
                      // Retry loading
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Example Cubit and State classes
class ExampleCubit extends Cubit<ExampleState> {
  ExampleCubit() : super(ExampleInitial());

  Future<void> loadData() async {
    emit(ExampleLoading());
    try {
      // Load data here
      await Future.delayed(const Duration(seconds: 2));
      emit(ExampleLoaded());
    } catch (e) {
      emit(ExampleError(e.toString()));
    }
  }
}

abstract class ExampleState {}

class ExampleInitial extends ExampleState {}

class ExampleLoading extends ExampleState {}

class ExampleLoaded extends ExampleState {}

class ExampleError extends ExampleState {
  final String message;
  ExampleError(this.message);
}
