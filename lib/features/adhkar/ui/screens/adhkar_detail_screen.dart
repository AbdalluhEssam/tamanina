import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/service_locator.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../cubit/adhkar_cubit.dart';
import '../widgets/adhkar_card.dart';

class AdhkarDetailScreen extends StatelessWidget {
  final AdhkarCategory category;

  const AdhkarDetailScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdhkarCubit(di.sl())..loadAdhkar(category),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AdhkarCubit, AdhkarState>(
            builder: (context, state) {
              if (state is AdhkarLoaded) {
                return Text(
                    context.read<AdhkarCubit>().getCategoryTitle(category));
              }
              return const Text('الأذكار');
            },
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<AdhkarCubit, AdhkarState>(
          builder: (context, state) {
            if (state is AdhkarLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              );
            }

            if (state is AdhkarError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AdhkarCubit>().loadAdhkar(category);
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is AdhkarLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.adhkarList.length,
                itemBuilder: (context, index) {
                  final adhkar = state.adhkarList[index];
                  return AdhkarCard(
                    adhkar: adhkar,
                    onCopy: () => _copyToClipboard(context, adhkar.arabicText),
                    onShare: () =>
                        _shareAdhkar(adhkar.arabicText, adhkar.translation),
                    onFavorite: () =>
                        context.read<AdhkarCubit>().toggleFavorite(adhkar.id),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ إلى الحافظة'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _shareAdhkar(String arabicText, String translation) {
    final String shareText = '$arabicText\n\n$translation';
    Share.share(shareText);
  }
}
