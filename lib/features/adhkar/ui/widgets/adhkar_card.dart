import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../../../statistics/data/worship_activity.dart';
import '../../data/models/adhkar_model.dart';

class AdhkarCard extends StatefulWidget {
  const AdhkarCard({
    super.key,
    required this.adhkar,
    required this.onFavorite,
    this.collection = 'default',
    this.onCopy,
    this.onShare,
  });

  final AdhkarModel adhkar;
  final String collection;
  final VoidCallback onFavorite;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  @override
  State<AdhkarCard> createState() => _AdhkarCardState();
}

class _AdhkarCardState extends State<AdhkarCard> {
  late final SharedPreferences _prefs;
  late final String _key;
  late int _count;

  @override
  void initState() {
    super.initState();
    _prefs = sl<SharedPreferences>();
    final today = WorshipLog.day(
      DateTime.now(),
    ).toIso8601String().split('T').first;
    _key = 'adhkar_${widget.collection}_${widget.adhkar.id}_$today';
    _count = (_prefs.getInt(_key) ?? 0).clamp(0, widget.adhkar.count);
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.adhkar;
    final theme = Theme.of(context);
    final done = _count >= entry.count;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              entry.arabicText,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
                height: 1.7,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.reference,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (entry.translation.isNotEmpty ||
                entry.transliteration.isNotEmpty ||
                entry.benefits.isNotEmpty)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  appText(context, 'المعنى والمعلومات', 'Meaning and details'),
                ),
                children: [
                  for (final text in [
                    entry.translation,
                    entry.transliteration,
                    entry.benefits,
                  ])
                    if (text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          text,
                          textAlign: TextAlign.start,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                ],
              ),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                FilledButton.tonal(
                  onPressed: done
                      ? null
                      : () {
                          setState(() => _count++);
                          unawaited(_prefs.setInt(_key, _count));
                          if (context
                              .read<SettingsCubit>()
                              .currentSettings
                              .vibrationEnabled) {
                            HapticFeedback.selectionClick();
                          }
                          if (_count == entry.count) {
                            unawaited(
                              WorshipLog.record(WorshipActivity.adhkar),
                            );
                          }
                        },
                  child: Text(
                    done
                        ? appText(context, 'اكتمل', 'Complete')
                        : appText(
                            context,
                            'عدّ التكرار ($_count/${entry.count})',
                            'Count ($_count/${entry.count})',
                          ),
                  ),
                ),
                IconButton(
                  tooltip: appText(context, 'المفضلة', 'Favorite'),
                  icon: Icon(
                    entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  onPressed: widget.onFavorite,
                ),
                IconButton(
                  tooltip: appText(context, 'نسخ', 'Copy'),
                  icon: const Icon(Icons.copy_outlined),
                  onPressed:
                      widget.onCopy ??
                      () async {
                        await Clipboard.setData(
                          ClipboardData(text: entry.arabicText),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                appText(context, 'تم النسخ', 'Copied'),
                              ),
                            ),
                          );
                        }
                      },
                ),
                Builder(
                  builder: (context) => IconButton(
                    tooltip: appText(context, 'مشاركة', 'Share'),
                    icon: Icon(Icons.adaptive.share),
                    onPressed:
                        widget.onShare ??
                        () {
                          final box = context.findRenderObject();
                          Share.share(
                            '${entry.arabicText}\n\n${entry.translation}',
                            sharePositionOrigin: box is RenderBox
                                ? box.localToGlobal(Offset.zero) & box.size
                                : null,
                          );
                        },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
