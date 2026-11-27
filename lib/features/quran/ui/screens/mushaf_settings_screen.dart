import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../../../settings/ui/screens/audio_library_screen.dart';
import '../../../settings/ui/screens/production_settings_screen.dart';
import '../../data/services/mushaf_settings.dart';
import '../../data/services/mushaf_library.dart';
import '../widgets/printed_mushaf_page.dart';

class MushafSettingsScreen extends StatefulWidget {
  const MushafSettingsScreen({super.key});

  @override
  State<MushafSettingsScreen> createState() => _MushafSettingsScreenState();
}

class _MushafSettingsScreenState extends State<MushafSettingsScreen> {
  late Future<MushafSettingsData> _load;
  MushafSettingsData? _updated;

  @override
  void initState() {
    super.initState();
    _load = MushafSettings.getAllSettings();
  }

  void _change(MushafSettingsData value) => setState(() => _updated = value);

  @override
  Widget build(BuildContext context) => FutureBuilder<MushafSettingsData>(
    future: _load,
    builder: (context, snapshot) {
      final settings = _updated ?? snapshot.data;
      final appTheme = Theme.of(context);
      final page = Scaffold(
        appBar: AppBar(
          title: Text(appText(context, 'ضبط القراءة', 'Reading settings')),
          actions: [
            if (settings != null)
              IconButton(
                icon: const Icon(Icons.restore),
                tooltip: appText(
                  context,
                  'استعادة الإعدادات',
                  'Restore defaults',
                ),
                onPressed: () async {
                  await MushafSettings.resetToDefaults();
                  final restored = await MushafSettings.getAllSettings();
                  if (mounted) _change(restored);
                },
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ContentFrame(
            child: settings == null
                ? snapshot.hasError
                      ? Center(
                          child: OutlinedButton(
                            onPressed: () => setState(
                              () => _load = MushafSettings.getAllSettings(),
                            ),
                            child: Text(
                              appText(context, 'إعادة المحاولة', 'Try again'),
                            ),
                          ),
                        )
                      : const ListSkeleton(rows: 4)
                : Builder(
                    builder: (context) => _options(
                      context,
                      settings,
                      allowReadingTheme: appTheme.brightness != Brightness.dark,
                    ),
                  ),
          ),
        ),
      );
      return Theme(
        data: AppTheme.readingTheme(
          appTheme,
          settings?.readingTheme ?? 'light',
        ),
        child: page,
      );
    },
  );

  Widget _options(
    BuildContext context,
    MushafSettingsData settings, {
    required bool allowReadingTheme,
  }) {
    final font = switch (settings.fontFamily) {
      'Scheherazade' => 'Scheherazade New',
      'NotoNaskhArabic' => 'Noto Naskh Arabic',
      final family => family,
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: MushafLayoutSwitch(
            printLayout: settings.printLayout,
            onChanged: (enabled) {
              _change(settings.copyWith(printLayout: enabled));
              MushafSettings.setPrintLayout(enabled);
            },
          ),
        ),
        const SizedBox(height: 14),
        if (!settings.printLayout) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                MushafLibrary.basmala,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: font,
                  fontSize: settings.fontSize,
                  height: settings.lineHeight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (!settings.printLayout || allowReadingTheme)
          Card(
            child: Column(
              children: [
                if (!settings.printLayout) ...[
                  settingsChoice<String>(
                    context,
                    icon: Icons.text_fields,
                    title: appText(context, 'خط المصحف', 'Quran typeface'),
                    current: settings.fontFamily,
                    values: MushafSettings.supportedFonts,
                    label: (key) => appText(
                      context,
                      MushafSettings.fontDisplayNames[key] ?? key,
                      key,
                    ),
                    onSelected: (value) {
                      _change(settings.copyWith(fontFamily: value));
                      MushafSettings.setFontFamily(value);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.record_voice_over_outlined),
                    title: Text(appText(context, 'القارئ', 'Reciter')),
                    trailing: Icon(appChevron(context)),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AudioLibraryScreen(
                          kind: AudioLibraryKind.reciter,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(appText(context, 'حجم الخط', 'Text size')),
                    subtitle: Slider(
                      value: settings.fontSize.clamp(
                        MushafSettings.minFontSize,
                        MushafSettings.maxFontSize,
                      ),
                      min: MushafSettings.minFontSize,
                      max: MushafSettings.maxFontSize,
                      divisions: 20,
                      label: settings.fontSizeLabel,
                      onChanged: (value) =>
                          _change(settings.copyWith(fontSize: value)),
                      onChangeEnd: MushafSettings.setFontSize,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      appText(context, 'تباعد الأسطر', 'Line spacing'),
                    ),
                    subtitle: Slider(
                      value: settings.lineHeight.clamp(
                        MushafSettings.minLineHeight,
                        MushafSettings.maxLineHeight,
                      ),
                      min: MushafSettings.minLineHeight,
                      max: MushafSettings.maxLineHeight,
                      divisions: 13,
                      label: settings.lineHeight.toStringAsFixed(1),
                      onChanged: (value) =>
                          _change(settings.copyWith(lineHeight: value)),
                      onChangeEnd: MushafSettings.setLineHeight,
                    ),
                  ),
                  SwitchListTile.adaptive(
                    title: Text(
                      appText(
                        context,
                        'ملاءمة أسطر الصفحة للشاشة',
                        'Fit page lines to screen',
                      ),
                    ),
                    subtitle: Text(
                      appText(
                        context,
                        'يكبّر الآيات حسب مساحة الشاشة. يمكنك التمرير بعد زيادة حجم الخط.',
                        'Fills the reading area. Scroll when you increase text size.',
                      ),
                    ),
                    value: settings.autoFit,
                    onChanged: (value) {
                      _change(settings.copyWith(autoFit: value));
                      MushafSettings.setAutoFit(value);
                    },
                  ),
                  SwitchListTile.adaptive(
                    title: Text(
                      appText(
                        context,
                        'عرض البسملة في مطلع السورة',
                        'Show opening basmala',
                      ),
                    ),
                    value: settings.showBasmala,
                    onChanged: (value) {
                      _change(settings.copyWith(showBasmala: value));
                      MushafSettings.setShowBasmala(value);
                    },
                  ),
                ],
                if (allowReadingTheme)
                  SwitchListTile.adaptive(
                    title: Text(
                      appText(
                        context,
                        'الوضع الداكن للمصحف',
                        'Dark mode for reading',
                      ),
                    ),
                    value: settings.darkMode,
                    onChanged: (value) {
                      _change(
                        settings.copyWith(
                          darkMode: value,
                          readingTheme: value ? 'dark' : 'light',
                        ),
                      );
                      MushafSettings.setDarkMode(value);
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
