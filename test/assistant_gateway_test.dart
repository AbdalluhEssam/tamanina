import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamanina/features/chatbot/data/services/assistant_gateway.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const request = {
    'message': 'ما فضل الصبر؟',
    'language': 'ar',
    'history': [
      {'role': 'user', 'content': 'مرحبا'},
    ],
  };

  http.Response groq(String answer) => http.Response.bytes(
    utf8.encode(
      jsonEncode({
        'choices': [
          {
            'message': {'content': answer},
          },
        ],
      }),
    ),
    200,
    headers: {'content-type': 'application/json'},
  );

  test('parses JSON settings and falls back to defaults', () {
    final settings = AssistantSettings.fromJson(
      '{"apiKey":" k ","model":"llama-3.1-8b-instant","dailyLimit":5,"enabled":false}',
    );
    expect(settings.apiKey, 'k');
    expect(settings.model, 'llama-3.1-8b-instant');
    expect(settings.dailyLimit, 5);
    expect(settings.enabled, isFalse);
    expect(settings.burstLimit, 8);
    expect(AssistantSettings.fromJson('not json').apiKey, isEmpty);
  });

  test('sends the configured request and decodes Arabic', () async {
    late Map<String, dynamic> body;
    late http.Request sent;
    final gateway = AssistantGateway(
      loadSettings: () async => const AssistantSettings(apiKey: 'key'),
      client: MockClient((http.Request value) async {
        sent = value;
        body = jsonDecode(value.body) as Map<String, dynamic>;
        return groq('الصبر مفتاح الفرج');
      }),
    );
    expect(await gateway.call(request), {'answer': 'الصبر مفتاح الفرج'});
    expect(sent.headers['Authorization'], 'Bearer key');
    expect(body['model'], 'openai/gpt-oss-20b');
    expect(body['reasoning_effort'], 'low');
    expect(body['max_completion_tokens'], 1600);
    final messages = body['messages'] as List;
    expect(messages.first['content'], contains('Reply in Arabic'));
    expect(messages.last, {'role': 'user', 'content': 'ما فضل الصبر؟'});
  });

  test('does nothing when disabled or without a key', () async {
    var calls = 0;
    final client = MockClient((_) async {
      calls++;
      return groq('x');
    });
    for (final settings in const [
      AssistantSettings(apiKey: 'key', enabled: false),
      AssistantSettings(),
    ]) {
      final gateway = AssistantGateway(
        loadSettings: () async => settings,
        client: client,
      );
      expect(await gateway.call(request), isNull);
    }
    expect(calls, 0);
  });

  test('enforces the per-device burst and daily limits', () async {
    var time = DateTime(2026, 11, 26, 12);
    final gateway = AssistantGateway(
      loadSettings: () async =>
          const AssistantSettings(apiKey: 'key', burstLimit: 2, dailyLimit: 3),
      client: MockClient((_) async => groq('ok')),
      now: () => time,
    );
    expect(await gateway.call(request), isNotNull);
    expect(await gateway.call(request), isNotNull);
    expect(await gateway.call(request), isNull);
    time = time.add(const Duration(minutes: 11));
    expect(await gateway.call(request), isNotNull);
    expect(await gateway.call(request), isNull);
    time = time.add(const Duration(hours: 25));
    expect(await gateway.call(request), isNotNull);
  });

  test('returns null when Groq fails', () async {
    final gateway = AssistantGateway(
      loadSettings: () async => const AssistantSettings(apiKey: 'key'),
      client: MockClient((_) async => http.Response('{}', 429)),
    );
    expect(await gateway.call(request), isNull);
  });

  group('streaming', () {
    String event(String piece) =>
        'data: ${jsonEncode({
          'choices': [
            {
              'delta': {'content': piece},
            },
          ],
        })}\n\n';

    test('yields the pieces of the answer and keeps Arabic intact', () async {
      final bytes = utf8.encode(
        '${event('بسم الله ')}${event('الرحمن')}: data: nonsense\n\ndata: [DONE]\n\n',
      );
      // Split in the middle of a multi-byte letter.
      final cut = 15;
      late Map<String, dynamic> body;
      final gateway = AssistantGateway(
        loadSettings: () async => const AssistantSettings(apiKey: 'key'),
        client: MockClient.streaming((request, bodyStream) async {
          body =
              jsonDecode(await bodyStream.bytesToString())
                  as Map<String, dynamic>;
          return http.StreamedResponse(
            Stream.fromIterable([bytes.sublist(0, cut), bytes.sublist(cut)]),
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }),
      );
      final pieces = await gateway.stream(request).toList();
      expect(pieces.join(), 'بسم الله الرحمن');
      expect(body['stream'], isTrue);
      final system = (body['messages'] as List).first['content'] as String;
      expect(system, contains('Markdown'));
      expect(system, contains('Reply in Arabic'));
    });

    test(
      'yields nothing when the request fails or the assistant is off',
      () async {
        final failing = AssistantGateway(
          loadSettings: () async => const AssistantSettings(apiKey: 'key'),
          client: MockClient.streaming(
            (request, _) async =>
                http.StreamedResponse(Stream.value(utf8.encode('error')), 500),
          ),
        );
        expect(await failing.stream(request).toList(), isEmpty);
        final off = AssistantGateway(
          loadSettings: () async => const AssistantSettings(),
        );
        expect(await off.stream(request).toList(), isEmpty);
      },
    );
  });
}
