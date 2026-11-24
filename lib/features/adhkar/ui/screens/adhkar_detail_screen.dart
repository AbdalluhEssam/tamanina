import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../cubit/adhkar_cubit.dart';
import '../widgets/adhkar_card.dart';
import 'adhkar_screen.dart';

class AdhkarDetailScreen extends StatefulWidget {
  const AdhkarDetailScreen({super.key, required this.category});

  final AdhkarCategory category;

  @override
  State<AdhkarDetailScreen> createState() => _AdhkarDetailScreenState();
}

class _AdhkarDetailScreenState extends State<AdhkarDetailScreen> {
  late final AdhkarCubit _cubit;
  bool _favorites = false;

  @override
  void initState() {
    super.initState();
    _cubit = sl<AdhkarCubit>()..loadAdhkar(widget.category);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _cubit,
    child: Scaffold(
      appBar: AppBar(
        title: Text(adhkarCategoryName(context, widget.category)),
        actions: [
          IconButton(
            onPressed: () => setState(() => _favorites = !_favorites),
            tooltip: _favorites
                ? appText(context, 'عرض الكل', 'Show all')
                : appText(context, 'عرض المفضلة', 'Show favorites'),
            icon: Icon(_favorites ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ContentFrame(
          child: BlocBuilder<AdhkarCubit, AdhkarState>(
            builder: (context, state) {
              if (state is AdhkarError) {
                return Center(
                  child: OutlinedButton(
                    onPressed: () => _cubit.loadAdhkar(widget.category),
                    child: Text(
                      appText(context, 'إعادة تحميل الأذكار', 'Reload adhkar'),
                    ),
                  ),
                );
              }
              if (state is! AdhkarLoaded) return const ListSkeleton();
              final entries = _favorites
                  ? state.adhkarList.where((entry) => entry.isFavorite).toList()
                  : state.adhkarList;
              if (entries.isEmpty) {
                return Center(
                  child: Text(
                    appText(
                      context,
                      'لا توجد أذكار في المفضلة.',
                      'No favorites in this collection.',
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return AdhkarCard(
                    key: ValueKey(entry.id),
                    adhkar: entry,
                    collection: widget.category.name,
                    onFavorite: () => _cubit.toggleFavorite(entry.id),
                  );
                },
              );
            },
          ),
        ),
      ),
    ),
  );
}
