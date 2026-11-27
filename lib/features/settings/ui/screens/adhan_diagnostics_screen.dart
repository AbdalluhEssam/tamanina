import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/services/adhan_native_bridge.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service_enhanced.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/widgets/tamanina_ui.dart';

/// Shows what decides whether the adhan can play on this phone and lets the
/// user test it. Android only.
class AdhanDiagnosticsScreen extends StatefulWidget {
  const AdhanDiagnosticsScreen({super.key});

  @override
  State<AdhanDiagnosticsScreen> createState() => _AdhanDiagnosticsScreenState();
}

class _AdhanDiagnosticsScreenState extends State<AdhanDiagnosticsScreen>
    with WidgetsBindingObserver {
  final _native = const AdhanNativeBridge();
  Map<String, Object?>? _data;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refresh());
  }

  Future<void> _refresh() async {
    final data = await _native.diagnostics();
    if (mounted) {
      setState(() {
        _data = data;
        _loading = false;
      });
    }
  }

  Future<void> _reschedule() async {
    await sl<NotificationServiceEnhanced>().refresh();
    await _refresh();
  }

  Future<void> _test() async {
    final volume = context.read<SettingsCubit>().currentSettings.adhanVolume;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final ok = await _native.scheduleTest(
      title: arabic ? 'اختبار الأذان' : 'Adhan test',
      stopLabel: arabic ? 'إيقاف الأذان' : 'Stop adhan',
      volume: volume <= 0 ? 1 : volume,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? appText(
                  context,
                  'سيبدأ الأذان بعد 10 ثوانٍ. اقفل الشاشة وانتظر.',
                  'The adhan starts in 10 seconds. Lock the screen and wait.',
                )
              : appText(
                  context,
                  'تعذّرت جدولة الاختبار.',
                  'The test could not be scheduled.',
                ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(seconds: 1));
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      appBar: AppBar(
        title: Text(appText(context, 'تشخيص الأذان', 'Adhan check')),
        actions: [
          IconButton(
            tooltip: appText(context, 'تحديث', 'Refresh'),
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? Center(
              child: Text(
                appText(
                  context,
                  'هذه الشاشة لأندرويد فقط.',
                  'This screen is for Android only.',
                ),
              ),
            )
          : ListView(children: _items(context, data)),
    );
  }

  String _time(Object? millis) => millis is int
      ? intl.DateFormat(
          'd MMM HH:mm:ss',
        ).format(DateTime.fromMillisecondsSinceEpoch(millis))
      : '—';

  Widget _row(
    BuildContext context, {
    required bool ok,
    required String ar,
    required String en,
    String? detailAr,
    String? detailEn,
    String? actionAr,
    String? actionEn,
    VoidCallback? action,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        ok ? Icons.check_circle : Icons.warning_amber_rounded,
        color: ok ? Colors.green : scheme.error,
      ),
      title: Text(appText(context, ar, en)),
      subtitle: detailAr == null
          ? null
          : Text(appText(context, detailAr, detailEn ?? detailAr)),
      trailing: !ok && action != null
          ? TextButton(
              onPressed: action,
              child: Text(
                appText(context, actionAr ?? 'إصلاح', actionEn ?? 'Fix'),
              ),
            )
          : null,
    );
  }

  List<Widget> _items(BuildContext context, Map<String, Object?> data) {
    final alarmVolume = data['alarmVolume'] as int? ?? 0;
    final alarmMax = data['alarmVolumeMax'] as int? ?? 1;
    final filter = data['interruptionFilter'] as int? ?? 1;
    final log = (data['log'] as List<Object?>? ?? const [])
        .cast<Map<Object?, Object?>>();
    final samsung = (data['manufacturer'] as String? ?? '')
        .toLowerCase()
        .contains('samsung');
    return [
      ListTile(
        title: Text('${data['manufacturer']} ${data['model']}'),
        subtitle: Text('Android ${data['sdk']}'),
      ),
      _row(
        context,
        ok: data['notificationsEnabled'] == true,
        ar: 'الإشعارات مسموحة',
        en: 'Notifications allowed',
        actionAr: 'فتح الإعدادات',
        actionEn: 'Open settings',
        action: openAppSettings,
      ),
      _row(
        context,
        ok: alarmVolume > 0,
        ar: 'صوت المنبّه مرتفع',
        en: 'Alarm volume is up',
        detailAr:
            'مستوى صوت المنبّه: $alarmVolume من $alarmMax. الأذان يشتغل على صوت المنبّه ويعمل حتى والهاتف صامت.',
        detailEn:
            'Alarm volume: $alarmVolume of $alarmMax. The adhan uses the alarm volume and plays even when the phone is on silent.',
        actionAr: 'فتح الإعدادات',
        actionEn: 'Open settings',
        action: openAppSettings,
      ),
      _row(
        context,
        ok: filter != 3,
        ar: 'وضع عدم الإزعاج لا يمنع المنبّهات',
        en: 'Do Not Disturb allows alarms',
        detailAr: filter == 3
            ? 'عدم الإزعاج على «صمت تام» ويمنع المنبّهات. اسمح بالمنبّهات من إعدادات عدم الإزعاج.'
            : null,
        detailEn: filter == 3
            ? 'Do Not Disturb is on “total silence” and blocks alarms. Allow alarms in its settings.'
            : null,
      ),
      _row(
        context,
        ok: data['batteryUnrestricted'] == true,
        ar: 'البطارية بلا قيود للتطبيق',
        en: 'Battery unrestricted for the app',
        detailAr: samsung
            ? 'على سامسونج: الإعدادات ← البطارية ← حدود استخدام الخلفية ← التطبيقات التي لا تنام أبدًا ← أضف طمأنينة، وأوقف «وضع التطبيقات غير المستخدمة للنوم».'
            : 'اسمح للتطبيق بالعمل في الخلفية بلا قيود حتى لا يوقف النظام الأذان.',
        detailEn: samsung
            ? 'On Samsung: Settings → Battery → Background usage limits → Never sleeping apps → add Tamanina, and turn off “Put unused apps to sleep”.'
            : 'Let the app run in the background without limits so the system does not stop the adhan.',
        actionAr: 'إعدادات البطارية',
        actionEn: 'Battery settings',
        action: _native.openBatterySettings,
      ),
      _row(
        context,
        ok: data['fullScreenAllowed'] == true,
        ar: 'الأذان على الشاشة المقفلة',
        en: 'Adhan screen over the lock screen',
        actionAr: 'السماح',
        actionEn: 'Allow',
        action: _native.openFullScreenIntentSettings,
      ),
      ListTile(
        leading: const Icon(Icons.alarm),
        title: Text(
          appText(
            context,
            'منبّهات الأذان المجدولة: ${data['scheduled']}',
            'Scheduled adhan alarms: ${data['scheduled']}',
          ),
        ),
        subtitle: Text(
          appText(
            context,
            'التالي: ${_time(data['nextAt'])}',
            'Next: ${_time(data['nextAt'])}',
          ),
        ),
        trailing: TextButton(
          onPressed: _reschedule,
          child: Text(appText(context, 'إعادة الجدولة', 'Reschedule')),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _test,
          icon: const Icon(Icons.play_circle_outline),
          label: Text(
            appText(
              context,
              'جرّب الأذان بعد 10 ثوانٍ',
              'Test the adhan in 10 seconds',
            ),
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.place_outlined),
        title: Text(appText(context, 'نتيجة تحديد المكان', 'Place lookup')),
        subtitle: Text(LocationService().lastPlacemark ?? '—'),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(
          appText(context, 'آخر الأحداث', 'Recent events'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      if (log.isEmpty)
        ListTile(
          title: Text(appText(context, 'لا أحداث بعد.', 'No events yet.')),
        ),
      for (final item in log)
        ListTile(
          dense: true,
          title: Text('${item['message']}'),
          subtitle: Text(_time(item['at'])),
        ),
    ];
  }
}
