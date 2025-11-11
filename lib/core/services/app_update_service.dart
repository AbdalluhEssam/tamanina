import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// App Update Service - Checks for app updates using Firebase Remote Config
class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  /// Initialize Remote Config
  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set default values
      await _remoteConfig.setDefaults({
        'latest_version_android': '1.0.0',
        'latest_version_ios': '1.0.0',
        'force_update': false,
        'update_message_ar': 'يتوفر تحديث جديد! يرجى التحديث إلى أحدث إصدار.',
        'update_message_en':
            'A new update is available! Please update to the latest version.',
        'play_store_url':
            'https://play.google.com/store/apps/details?id=com.abdalluh.tamanina',
        'app_store_url': 'https://apps.apple.com/app/id123456789',
      });

      await _remoteConfig.fetchAndActivate();

      if (kDebugMode) {
        print('✅ Remote Config initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Remote Config: $e');
      }
    }
  }

  /// Check for app updates
  Future<void> checkForUpdates(BuildContext context) async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Get latest version from Remote Config
      final latestVersion = Platform.isAndroid
          ? _remoteConfig.getString('latest_version_android')
          : _remoteConfig.getString('latest_version_ios');

      final forceUpdate = _remoteConfig.getBool('force_update');

      if (kDebugMode) {
        print('📱 Current Version: $currentVersion');
        print('🆕 Latest Version: $latestVersion');
        print('⚠️ Force Update: $forceUpdate');
      }

      // Compare versions
      if (_isUpdateAvailable(currentVersion, latestVersion)) {
        if (context.mounted) {
          _showUpdateDialog(context, forceUpdate);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking for updates: $e');
      }
    }
  }

  /// Compare version strings
  bool _isUpdateAvailable(String currentVersion, String latestVersion) {
    try {
      final current = currentVersion.split('.').map(int.parse).toList();
      final latest = latestVersion.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final currentPart = i < current.length ? current[i] : 0;
        final latestPart = i < latest.length ? latest[i] : 0;

        if (latestPart > currentPart) return true;
        if (latestPart < currentPart) return false;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error comparing versions: $e');
      }
      return false;
    }
  }

  /// Show update dialog
  void _showUpdateDialog(BuildContext context, bool forceUpdate) {
    final messageAr = _remoteConfig.getString('update_message_ar');
    final messageEn = _remoteConfig.getString('update_message_en');

    // Determine current locale (you can improve this based on your app's locale logic)
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final message = isArabic ? messageAr : messageEn;

    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => !forceUpdate,
          child: AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.system_update, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isArabic ? 'تحديث متاح' : 'Update Available',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
                if (forceUpdate) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isArabic
                                ? 'هذا التحديث إلزامي'
                                : 'This update is mandatory',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    isArabic ? 'لاحقاً' : 'Later',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ElevatedButton.icon(
                onPressed: () => _openStore(),
                icon: const Icon(Icons.download),
                label: Text(
                  isArabic ? 'تحديث الآن' : 'Update Now',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Open the appropriate app store
  Future<void> _openStore() async {
    try {
      final url = Platform.isAndroid
          ? _remoteConfig.getString('play_store_url')
          : _remoteConfig.getString('app_store_url');

      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (kDebugMode) {
          print('❌ Could not launch $url');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error opening store: $e');
      }
    }
  }

  /// Manually trigger update check
  Future<void> manualCheckForUpdates(BuildContext context) async {
    await _remoteConfig.fetchAndActivate();
    await checkForUpdates(context);
  }

  /// Get a specific Remote Config value
  String getConfigValue(String key) {
    return _remoteConfig.getString(key);
  }

  /// Get a boolean Remote Config value
  bool getConfigBool(String key) {
    return _remoteConfig.getBool(key);
  }

  /// Get an int Remote Config value
  int getConfigInt(String key) {
    return _remoteConfig.getInt(key);
  }
}
