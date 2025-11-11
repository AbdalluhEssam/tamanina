import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/service_locator.dart' as di;
import '../cubit/audio_cubit.dart';
import '../cubit/quran_cubit.dart';
import 'quran_audio_page.dart';

/// Entry screen showing the list of surahs.
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuranCubit>().loadSurahs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
      ),
      body: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          if (state.status == QuranStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == QuranStatus.error) {
            return Center(
              child: Text(state.errorMessage ?? 'تعذر تحميل القرآن الكريم'),
            );
          }

          if (state.surahs.isEmpty) {
            return const Center(child: Text('لا توجد بيانات متاحة حالياً'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: state.surahs.length,
            itemBuilder: (context, index) {
              final surah = state.surahs[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(surah.surahNameArabic, textAlign: TextAlign.end),
                  subtitle:
                      Text(surah.surahNameEnglish, textAlign: TextAlign.end),
                  leading: CircleAvatar(
                    child: Text(surah.surahNumber.toString()),
                  ),
                  trailing: const Icon(Icons.arrow_back_ios_new),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(
                              value: context.read<QuranCubit>(),
                            ),
                            BlocProvider(
                              create: (_) => di.sl<AudioCubit>(),
                            ),
                          ],
                          child: QuranAudioPage(surahId: surah.surahNumber),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
