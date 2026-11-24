import 'dart:io';

import 'package:flutter/material.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/tamanina_ui.dart';

class AppUpdateService {
  factory AppUpdateService() => _instance;
  AppUpdateService._();
  static final _instance = AppUpdateService._();

  final _store = NewVersionPlus(
    iOSId: const String.fromEnvironment(
      'TAMANINA_IOS_STORE_BUNDLE_ID',
      defaultValue: 'com.abdalluh.tamanina',
    ),
    androidId: const String.fromEnvironment(
      'TAMANINA_ANDROID_STORE_PACKAGE',
      defaultValue: 'com.abdalluh.tamanina',
    ),
    iOSAppStoreCountry: const String.fromEnvironment(
      'TAMANINA_STORE_COUNTRY',
      defaultValue: 'EG',
    ),
  );
  bool _checking = false;
  static const _lastCheckKey = 'store_update_last_check';

  Future<void> manualCheckForUpdates(BuildContext context) =>
      _check(context, automatic: false);

  Future<void> checkForUpdates(BuildContext context) =>
      _check(context, automatic: true);

  Future<void> _check(BuildContext context, {required bool automatic}) async {
    if (_checking || (!Platform.isAndroid && !Platform.isIOS)) return;
    _checking = true;
    try {
      if (automatic) {
        final prefs = await SharedPreferences.getInstance();
        final last = prefs.getInt(_lastCheckKey);
        final now = DateTime.now().millisecondsSinceEpoch;
        if (last != null &&
            now - last < const Duration(hours: 24).inMilliseconds) {
          return;
        }
        await prefs.setInt(_lastCheckKey, now);
      }

      final status = await _store.getVersionStatus().timeout(
        const Duration(seconds: 8),
      );
      if (!context.mounted || ModalRoute.of(context)?.isCurrent == false) {
        return;
      }
      if (status == null ||
          status.originalStoreVersion?.trim().isNotEmpty != true) {
        if (!automatic) _showUnavailable(context);
        return;
      }

      final link = Uri.tryParse(status.appStoreLink);
      final hasStoreLink =
          link != null &&
          link.scheme == 'https' &&
          const {
            'play.google.com',
            'apps.apple.com',
            'itunes.apple.com',
          }.contains(link.host);
      if (status.canUpdate && hasStoreLink) {
        final accepted = await showAdaptiveDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => AlertDialog.adaptive(
            title: Text(
              appText(
                context,
                'تحديث جديد لطمأنينة',
                'Tamanina update available',
              ),
            ),
            content: Text(
              appText(
                context,
                'تقدر تنزّل الإصدار ${status.storeVersion} من المتجر.',
                'Version ${status.storeVersion} is available in the store.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(appText(context, 'لاحقًا', 'Later')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(appText(context, 'افتح المتجر', 'Open store')),
              ),
            ],
          ),
        );
        if (accepted == true && context.mounted) {
          final opened = await launchUrl(
            link,
            mode: LaunchMode.externalApplication,
          );
          if (!opened && context.mounted) _showUnavailable(context);
        }
      } else if (!automatic) {
        if (status.canUpdate) {
          _showUnavailable(context);
        } else {
          _message(
            context,
            'أنت تستخدم أحدث إصدار متاح.',
            'You’re using the latest available version.',
          );
        }
      }
    } catch (_) {
      if (!automatic && context.mounted) _showUnavailable(context);
    } finally {
      _checking = false;
    }
  }

  void _showUnavailable(BuildContext context) => _message(
    context,
    'تعذّر التحقق من المتجر. جرّب مرة أخرى عند الاتصال.',
    'Could not reach the store. Try again when connected.',
  );

  void _message(BuildContext context, String arabic, String english) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(appText(context, arabic, english))));
  }
}
