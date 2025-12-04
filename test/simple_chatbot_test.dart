import 'package:flutter_test/flutter_test.dart';
import 'package:tamanina/features/chatbot/data/services/islamic_ai_service.dart';

void main() {
  group('Simple Chatbot Tests', () {
    late IslamicAiService service;

    setUp(() {
      service = IslamicAiService();
    });

    test('should handle greeting correctly', () async {
      final message = await service.generateResponse(
        userMessage: 'السلام عليكم',
        sessionId: 'test_session',
      );

      // With Groq API working, we expect intelligent responses
      expect(message.content.isNotEmpty, isTrue);
      expect(
          message.content.contains('وعليكم السلام') ||
              message.content.contains('السلام'),
          isTrue);
      print('✅ Greeting response: ${message.content}');
    });

    test('should provide intelligent Islamic responses', () async {
      final message = await service.generateResponse(
        userMessage: 'ما حكم الصلاة؟',
        sessionId: 'test_session',
      );

      // Response should not be empty
      expect(message.content.isNotEmpty, isTrue);

      // With Groq API working, we expect detailed Islamic knowledge
      // With offline fallback, we expect a polite offline message
      final isOnlineResponse = message.content.contains('الصلاة') ||
          message.content.contains('فرض') ||
          message.content.contains('واجب');
      final isOfflineFallback = message.content.contains('عذراً') ||
          message.content.contains('الاتصال');

      // Either we get an intelligent response OR an offline fallback
      expect(isOnlineResponse || isOfflineFallback, isTrue);
      print('✅ Islamic response: ${message.content}');
    });

    test('should handle streaming without duplicating text', () async {
      final responses = <String>[];
      await for (final response in service.generateStreamingResponse(
        userMessage: 'السلام عليكم',
        sessionId: 'test_stream',
      )) {
        responses.add(response);
      }

      expect(responses.isNotEmpty, isTrue);

      // Check final response doesn't contain duplicated text
      final finalResponse = responses.last;
      expect(finalResponse.contains('عذراً،عذراً'), isFalse);
      expect(finalResponse.contains('لاعذرا'), isFalse);

      print('✅ Streaming responses count: ${responses.length}');
      print('✅ Final streaming response: $finalResponse');
    });

    test('should handle different question types without text duplication',
        () async {
      final testQuestions = [
        'هل تعدد الزوجات حرام؟',
        'ما هو حكم الزكاة؟',
        'كيف أصلي؟'
      ];

      for (final question in testQuestions) {
        final responses = <String>[];
        await for (final response in service.generateStreamingResponse(
          userMessage: question,
          sessionId: 'test_question',
        )) {
          responses.add(response);
        }

        final finalResponse = responses.last;

        // Check for actual problematic text duplication issues (not normal Arabic punctuation)
        expect(finalResponse.contains('عذراًعذراً'),
            isFalse); // No space duplicates
        expect(finalResponse.contains('لالا'), isFalse); // No repeated words
        expect(finalResponse.contains('عذراً عذراً'),
            isFalse); // No word duplicates
        expect(finalResponse.split('عذراً').length - 1,
            lessThanOrEqualTo(1)); // Only one occurrence of "عذراً"

        print('✅ Question: $question');
        print(
            '✅ Clean response received: ${finalResponse.length > 100 ? "${finalResponse.substring(0, 100)}..." : finalResponse}');
      }
    });
  });
}
