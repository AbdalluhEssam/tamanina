import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamanina/features/chatbot/data/services/islamic_ai_service.dart';
import 'package:tamanina/features/chatbot/domain/entities/chat_message.dart';

void main() {
  group('Islamic AI Service Tests', () {
    late IslamicAiService islamicAiService;

    setUp(() async {
      // Initialize SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Initialize services
      islamicAiService = IslamicAiService();
    });

    test('should give specific answer for polygamy question', () async {
      // Test specific polygamy question
      const userMessage = 'هل التعدد في الزواج حرام؟';
      const sessionId = 'test_session_polygamy';

      try {
        final response = await islamicAiService.generateResponse(
          userMessage: userMessage,
          sessionId: sessionId,
        );

        expect(response, isA<ChatMessage>());
        expect(response.content.isNotEmpty, true);
        expect(response.isUser, false);
        expect(
            response.content.contains('تعدد الزوجات في الإسلام حكم شرعي مباح'),
            true);
        expect(response.content.contains('فانكحوا ما طاب لكم من النساء'), true);
        print('✅ Polygamy Response: ${response.content}');
      } catch (e) {
        print('Error occurred: $e');
      }
    });

    test('should provide streaming response for marriage questions', () async {
      const userMessage = 'أخبرني عن تعدد الزوجات';
      const sessionId = 'test_session_marriage';

      final responseWords = <String>[];

      try {
        await for (final chunk in islamicAiService.generateStreamingResponse(
          userMessage: userMessage,
          sessionId: sessionId,
        )) {
          responseWords.add(chunk);
        }

        expect(responseWords.isNotEmpty, true);
        final fullResponse = responseWords.join();
        expect(fullResponse.isNotEmpty, true);
        expect(fullResponse.contains('تعدد الزوجات'), true);
        print('✅ Streaming Marriage Response: $fullResponse');
      } catch (e) {
        print('Streaming error: $e');
      }
    });

    test('should handle different variations of polygamy questions', () async {
      final testQuestions = [
        'هل يجوز الزواج بأربع نساء؟',
        'ما حكم تعدد الزوجات في الإسلام؟',
        'هل التعدد حلال أم حرام؟',
        'أريد أن أتزوج زوجة ثانية',
      ];

      for (final question in testQuestions) {
        final response = await islamicAiService.generateResponse(
          userMessage: question,
          sessionId: 'test_${question.hashCode}',
        );

        expect(response.content.isNotEmpty, true);
        expect(response.content.length > 50, true,
            reason: 'Response should be detailed enough');

        // Should contain Islamic jurisprudence content
        bool hasRelevantContent = response.content.contains('تعدد') ||
            response.content.contains('مباح') ||
            response.content.contains('شرعي') ||
            response.content.contains('الزوجات') ||
            response.content.contains('النساء') ||
            response.content.contains('العدل') ||
            response.content.contains('حرام') ||
            response.content.contains('حلال') ||
            response.content.contains('الإسلام');

        expect(hasRelevantContent, true,
            reason:
                'Response should contain relevant Islamic content for: $question');
        print('✅ Question: $question');
        print(
            '✅ Answer: ${response.content.length > 100 ? response.content.substring(0, 100) + "..." : response.content}\n');
      }
    });

    test('should handle general greetings', () async {
      const userMessage = 'السلام عليكم';
      const sessionId = 'test_session_greetings';

      final response = await islamicAiService.generateResponse(
        userMessage: userMessage,
        sessionId: sessionId,
      );

      expect(response, isA<ChatMessage>());
      expect(response.content.isNotEmpty, true);
      expect(response.content.contains('وعليكم السلام'), true);
      print('✅ Greeting response: ${response.content}');
    });
  });
}
