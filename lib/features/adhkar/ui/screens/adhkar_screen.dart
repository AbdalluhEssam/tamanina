import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/service_locator.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../cubit/adhkar_cubit.dart';
import 'adhkar_detail_screen.dart';

class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdhkarCubit(di.sl()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأذكار'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCategoryCard(
                context,
                'أذكار الصباح',
                Icons.wb_sunny,
                AdhkarCategory.morning,
                AppColors.primaryGreen.withOpacity(0.1),
              ),
              _buildCategoryCard(
                context,
                'أذكار المساء',
                Icons.nightlight_round,
                AdhkarCategory.evening,
                AppColors.goldAccent.withOpacity(0.1),
              ),
              _buildCategoryCard(
                context,
                'أذكار النوم',
                Icons.bed,
                AdhkarCategory.sleep,
                Colors.purple.withOpacity(0.1),
              ),
              _buildCategoryCard(
                context,
                'أذكار بعد الصلاة',
                Icons.mosque,
                AdhkarCategory.postPrayer,
                Colors.blue.withOpacity(0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    AdhkarCategory category,
    Color backgroundColor,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdhkarDetailScreen(category: category),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
