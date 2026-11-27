import 'package:flutter_test/flutter_test.dart';
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
      final service = IslamicAiService(
        assistantCall: (request) async {
          expect(request['message'], 'What is the wisdom behind fasting?');
          expect(request['language'], 'ar');
          expect(request['history'], [
            {'role': 'user', 'content': 'Tell me about Ramadan.'},
          ]);
          return {'answer': 'A test answer'};
        },
      );
      final answer = await service.generateResponse(
        userMessage: 'What is the wisdom behind fasting?',
        sessionId: 'test',
        context: [ChatMessage.user(id: '1', content: 'Tell me about Ramadan.')],
      );
      expect(answer.content, 'A test answer');
    },
  );

  test('a failing assistant call falls back to the offline message', () async {
    final service = IslamicAiService(
      assistantCall: (_) async => throw Exception('offline'),
    );
    final answer = await service.generateResponse(
      userMessage: 'What is the wisdom behind fasting?',
      sessionId: 'test',
    );
    expect(answer.content, contains('غير متاح'));
  });

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

  group('streaming answers', () {
    test('the AI answer arrives piece by piece as growing text', () async {
      final service = IslamicAiService(
        assistantStream: (request) async* {
          for (final piece in ['الصبر ', 'مفتاح ', 'الفرج']) {
            yield piece;
            await Future<void>.delayed(const Duration(milliseconds: 60));
          }
        },
      );
      final seen = await service
          .generateStreamingResponse(
            userMessage: 'ما فضل الصبر؟',
            sessionId: 's',
          )
          .toList();
      expect(seen.last, 'الصبر مفتاح الفرج');
      expect(seen.length, greaterThan(1));
      for (var i = 1; i < seen.length; i++) {
        expect(seen[i].startsWith(seen[i - 1]), isTrue);
      }
    });

    test('instant local answers are revealed word by word', () async {
      final seen = await IslamicAiService()
          .generateStreamingResponse(
            userMessage: 'كيف أتابع قراءة القرآن؟',
            sessionId: 's',
          )
          .toList();
      expect(seen.length, greaterThan(3));
      expect(seen.last, contains('تابع القراءة'));
    });

    test(
      'when streaming gives nothing the unavailable message is shown',
      () async {
        final service = IslamicAiService(
          assistantStream: (request) => const Stream.empty(),
        );
        final seen = await service
            .generateStreamingResponse(
              userMessage: 'سؤال عام جدا',
              sessionId: 's',
            )
            .toList();
        expect(seen.last, contains('غير متاح'));
      },
    );
  });
}
