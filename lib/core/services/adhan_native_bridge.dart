import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Playback state of the Android adhan service.
class NativeAdhanStatus {
  const NativeAdhanStatus({
    required this.playing,
    required this.position,
    required this.duration,
  });

  static const idle = NativeAdhanStatus(
    playing: false,
    position: Duration.zero,
    duration: Duration.zero,
  );

  final bool playing;
  final Duration position;
  final Duration duration;
}

/// Controls the adhan that Android plays from its background service, so the
/// full-screen adhan screen can follow it instead of starting a second player.
class AdhanNativeBridge {
  const AdhanNativeBridge();

  static const _channel = MethodChannel('com.abdalluh.tamanina/adhan_alarms');

  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<NativeAdhanStatus> status() async {
    if (!supported) return NativeAdhanStatus.idle;
    try {
      final data = await _channel.invokeMapMethod<String, Object?>('status');
      return NativeAdhanStatus(
        playing: data?['playing'] == true,
        position: Duration(milliseconds: (data?['positionMs'] as int?) ?? 0),
        duration: Duration(milliseconds: (data?['durationMs'] as int?) ?? 0),
      );
    } on PlatformException {
      return NativeAdhanStatus.idle;
    } on MissingPluginException {
      return NativeAdhanStatus.idle;
    }
  }

  Future<void> stop() => _invoke('stop');

  /// Closes the app when it was opened over the lock screen by the adhan.
  Future<void> closeOverLockScreen() => _invoke('closeOverLockScreen');

  Future<bool> canUseFullScreenIntent() async {
    if (!supported) return true;
    try {
      return await _channel.invokeMethod<bool>('canUseFullScreenIntent') ??
          true;
    } on PlatformException {
      return true;
    } on MissingPluginException {
      return true;
    }
  }

  Future<void> openFullScreenIntentSettings() =>
      _invoke('openFullScreenIntentSettings');

  Future<void> openBatterySettings() => _invoke('openBatterySettings');

  /// Everything that decides whether the adhan can play, plus recent outcomes.
  Future<Map<String, Object?>?> diagnostics() async {
    if (!supported) return null;
    try {
      return await _channel.invokeMapMethod<String, Object?>('diagnostics');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Schedules an adhan about ten seconds from now to test the whole chain.
  Future<bool> scheduleTest({
    required String title,
    required String stopLabel,
    required double volume,
  }) async {
    if (!supported) return false;
    try {
      return await _channel.invokeMethod<bool>('scheduleTest', {
            'title': title,
            'stopLabel': stopLabel,
            'volume': volume,
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> _invoke(String method) async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<void>(method);
    } on PlatformException {
      // The adhan may already have finished.
    } on MissingPluginException {
      // Not available in tests or on unsupported platforms.
    }
  }
}
