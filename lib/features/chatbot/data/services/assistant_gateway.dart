import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/remote_settings.dart';

const _defaultSystemPrompt =
    'You are the Tamanina assistant for an Islamic companion app. '
    'Answer concisely in the requested language. '
    'Do not invent Quran quotations, hadith, or sources. '
    'For individual religious rulings, explain the limits of a general answer '
    'and refer the user to a qualified scholar.';

/// Appended to whatever system prompt Remote Config provides, so the answer
/// style stays consistent even when the prompt is edited remotely.
const _answerStyle =
    ' Write like a warm, knowledgeable assistant in a chat app: open with a '
    'direct answer, then explain in short, well-organised paragraphs. Use '
    'Markdown where it helps (**bold** for key terms, "-" bullets, numbered '
    'steps) and keep it natural, not robotic. Give a complete answer (usually '
    '120-300 words) unless the user asks for brief. For questions where '
    'scholars differ, say so briefly. Quote Quran or hadith only when you are '
    'certain of the wording, and name the surah and verse number.';

/// Assistant settings. They come from the Firebase Remote Config parameter
/// `assistant` (a JSON value), so the key, model and limits can change without
/// an app release. Missing fields use the defaults below.
class AssistantSettings {
  const AssistantSettings({
    this.enabled = true,
    this.apiKey = '',
    this.model = 'openai/gpt-oss-20b',
    this.reasoningEffort = 'low',
    this.maxTokens = 1600,
    this.burstLimit = 8,
    this.windowMinutes = 10,
    this.dailyLimit = 30,
    this.systemPrompt = _defaultSystemPrompt,
  });

  factory AssistantSettings.fromJson(String source) {
    try {
      final json = jsonDecode(source);
      if (json is! Map) return const AssistantSettings();
      T pick<T>(String key, T fallback) {
        final value = json[key];
        if (value is T && !(value is String && value.isEmpty)) return value;
        return fallback;
      }

      int number(String key, int fallback) {
        final value = json[key];
        return value is num && value >= 0 ? value.toInt() : fallback;
      }

      const defaults = AssistantSettings();
      return AssistantSettings(
        enabled: pick('enabled', defaults.enabled),
        apiKey: pick('apiKey', defaults.apiKey).trim(),
        model: pick('model', defaults.model),
        reasoningEffort: pick('reasoningEffort', defaults.reasoningEffort),
        maxTokens: number('maxTokens', defaults.maxTokens),
        burstLimit: number('burstLimit', defaults.burstLimit),
        windowMinutes: number('windowMinutes', defaults.windowMinutes),
        dailyLimit: number('dailyLimit', defaults.dailyLimit),
        systemPrompt: pick('systemPrompt', defaults.systemPrompt),
      );
    } catch (_) {
      return const AssistantSettings();
    }
  }

  final bool enabled;
  final String apiKey;
  final String model;
  final String reasoningEffort;
  final int maxTokens;
  final int burstLimit;
  final int windowMinutes;
  final int dailyLimit;
  final String systemPrompt;
}

Future<AssistantSettings> loadRemoteAssistantSettings() async =>
    AssistantSettings.fromJson((await remoteConfig()).getString('assistant'));

/// Sends assistant questions to Groq with the key and limits from Remote
/// Config. Returns `{'answer': ...}`, or null when the assistant is off, the
/// device limit is reached, or the request fails.
class AssistantGateway {
  AssistantGateway({
    Future<AssistantSettings> Function()? loadSettings,
    http.Client? client,
    DateTime Function()? now,
  }) : _loadSettings = loadSettings ?? loadRemoteAssistantSettings,
       _client = client,
       _now = now ?? DateTime.now;

  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _hitsKey = 'assistant_hits';

  final Future<AssistantSettings> Function() _loadSettings;
  final http.Client? _client;
  final DateTime Function() _now;
  AssistantSettings? _settings;
  DateTime? _loadedAt;

  Future<AssistantSettings> _currentSettings() async {
    final loadedAt = _loadedAt;
    if (_settings == null ||
        loadedAt == null ||
        _now().difference(loadedAt) > const Duration(minutes: 5)) {
      _settings = await _loadSettings();
      _loadedAt = _now();
    }
    return _settings!;
  }

  Future<bool> _takeQuota(AssistantSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    final now = _now().millisecondsSinceEpoch;
    final day = const Duration(days: 1).inMilliseconds;
    final window = Duration(minutes: settings.windowMinutes).inMilliseconds;
    final hits = [
      for (final hit in preferences.getStringList(_hitsKey) ?? const <String>[])
        if (int.tryParse(hit) case final time? when now - time < day) time,
    ];
    final recent = hits.where((time) => now - time < window).length;
    if (recent >= settings.burstLimit || hits.length >= settings.dailyLimit) {
      return false;
    }
    await preferences.setStringList(_hitsKey, [
      for (final hit in hits) '$hit',
      '$now',
    ]);
    return true;
  }

  Map<String, String> _headers(AssistantSettings settings) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${settings.apiKey}',
  };

  Map<String, Object?> _body(
    AssistantSettings settings,
    Map<String, Object?> request, {
    required bool stream,
  }) {
    final language = request['language'] == 'ar' ? 'Arabic' : 'English';
    final history = request['history'];
    return {
      'model': settings.model,
      'messages': [
        {
          'role': 'system',
          'content':
              '${settings.systemPrompt}$_answerStyle Reply in $language.',
        },
        if (history is List) ...history,
        {'role': 'user', 'content': request['message']},
      ],
      'max_completion_tokens': settings.maxTokens,
      if (stream) 'stream': true,
      if (settings.model.startsWith('openai/gpt-oss') &&
          settings.reasoningEffort.isNotEmpty)
        'reasoning_effort': settings.reasoningEffort,
    };
  }

  /// Streams the answer as it is written: each event is the next piece of text.
  /// It yields nothing when the assistant is off, the device limit is reached,
  /// or the request fails.
  Stream<String> stream(Map<String, Object?> request) async* {
    final settings = await _currentSettings();
    if (!settings.enabled || settings.apiKey.isEmpty) return;
    if (!await _takeQuota(settings)) return;
    final client = _client ?? http.Client();
    try {
      final call = http.Request('POST', Uri.parse(_endpoint))
        ..headers.addAll(_headers(settings))
        ..body = jsonEncode(_body(settings, request, stream: true));
      final response = await client
          .send(call)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        await response.stream.drain<void>();
        return;
      }
      // Server-sent events: "data: {json}" lines, ending with "data: [DONE]".
      // Decoding the byte stream as UTF-8 keeps Arabic letters intact when a
      // character is split between network chunks.
      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      await for (final line in lines.timeout(const Duration(seconds: 30))) {
        if (!line.startsWith('data:')) continue;
        final data = line.substring(5).trim();
        if (data == '[DONE]') break;
        try {
          final json = jsonDecode(data);
          final choices = json is Map ? json['choices'] : null;
          final delta = choices is List && choices.isNotEmpty
              ? (choices.first as Map)['delta']
              : null;
          final piece = delta is Map ? delta['content'] : null;
          if (piece is String && piece.isNotEmpty) yield piece;
        } on FormatException {
          continue;
        }
      }
    } finally {
      if (_client == null) client.close();
    }
  }

  Future<Object?> call(Map<String, Object?> request) async {
    final settings = await _currentSettings();
    if (!settings.enabled || settings.apiKey.isEmpty) return null;
    if (!await _takeQuota(settings)) return null;

    final response = await (_client?.post ?? http.post)(
      Uri.parse(_endpoint),
      headers: _headers(settings),
      body: jsonEncode(_body(settings, request, stream: false)),
    );
    if (response.statusCode != 200) return null;
    // Groq omits the charset, so decode the bytes as UTF-8 for Arabic text.
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    final choices = body is Map ? body['choices'] : null;
    final message = choices is List && choices.isNotEmpty
        ? (choices.first as Map)['message']
        : null;
    final content = message is Map ? message['content'] : null;
    return content is String && content.trim().isNotEmpty
        ? {'answer': content.trim()}
        : null;
  }
}
