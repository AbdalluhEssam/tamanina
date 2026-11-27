import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

Future<FirebaseRemoteConfig>? _ready;

/// Fetches Firebase Remote Config once per run (at most hourly in release
/// builds). Parameters: `assistant` (Groq settings) and `audio_catalog`.
Future<FirebaseRemoteConfig> remoteConfig() =>
    _ready ??= _load().onError((error, stackTrace) {
      _ready = null;
      Error.throwWithStackTrace(error!, stackTrace);
    });

Future<FirebaseRemoteConfig> _load() async {
  final config = FirebaseRemoteConfig.instance;
  await config.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: kReleaseMode
          ? const Duration(hours: 1)
          : Duration.zero,
    ),
  );
  await config.setDefaults(const {'assistant': '{}', 'audio_catalog': '{}'});
  try {
    await config.fetchAndActivate();
  } catch (_) {
    // Keep the last activated values.
  }
  return config;
}
