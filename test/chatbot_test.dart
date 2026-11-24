import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tamanina/features/chatbot/data/model/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamanina/features/chatbot/data/model/chat_session.dart';
import 'package:tamanina/features/chatbot/data/repo/chatbot_repository_impl.dart';
import 'package:tamanina/features/chatbot/data/services/islamic_ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('an offline question and its answer persist in chat history', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = ChatbotRepositoryImpl(
      sharedPreferences: preferences,
      aiService: IslamicAiService(),
    );
    final session = ChatSession.create(id: 'guide', userId: 'user');
    await repository.saveChatSession(session);
    final answer = await repository.sendMessage(
      sessionId: session.id,
      userId: session.userId,
      userMessage: 'كيف أتابع قراءة القرآن؟',
    );
    expect(answer.content, contains('تابع القراءة'));
    expect(answer.isUser, isFalse);
    final history = await repository.getChatHistory(session.userId);
    expect(history.single.messages.map((message) => message.isUser), [
      true,
      false,
    ]);
    expect(history.single.messages.last.content, answer.content);
  });

  test(
    'open-ended questions send recent turns to the configured assistant',
    () async {
      final endpoint = Uri.parse('https://example.invalid/guide');
      final service = IslamicAiService(
        endpoint: endpoint,
        client: MockClient((request) async {
          expect(request.url, endpoint);
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['message'], 'What is the wisdom behind fasting?');
          expect(body['history'], [
            {'role': 'user', 'content': 'Tell me about Ramadan.'},
          ]);
          return http.Response('{"answer":"A test answer"}', 200);
        }),
      );
      final answer = await service.generateResponse(
        userMessage: 'What is the wisdom behind fasting?',
        sessionId: 'test',
        context: [ChatMessage.user(id: '1', content: 'Tell me about Ramadan.')],
      );
      expect(answer.content, 'A test answer');
    },
  );

  test(
    'an unhandled religious question points to a qualified scholar',
    () async {
      final message = await IslamicAiService().generateResponse(
        userMessage: 'هل التعدد في الزواج حرام؟',
        sessionId: 'local',
      );
      expect(message.content, contains('عالم موثوق'));
    },
  );
}
