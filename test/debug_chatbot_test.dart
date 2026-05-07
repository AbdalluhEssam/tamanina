import 'package:flutter_test/flutter_test.dart';
import 'package:tamanina/features/chatbot/data/services/islamic_ai_service.dart';

void main() {
  group('Debug Chatbot', () {
    test('should show exact text duplication issue', () async {
      final service = IslamicAiService();

      final responses = <String>[];
      await for (final response in service.generateStreamingResponse(
        userMessage: 'هل تعدد الزوجات حرام؟',
        sessionId: 'debug_test',
      )) {
        responses.add(response);
      }

      final finalResponse = responses.last;
      print('📝 Final response content: "$finalResponse"');
      print('📏 Response length: ${finalResponse.length}');

      // Check for specific duplication patterns
      if (finalResponse.contains('عذراً،عذراً')) {
        print('❌ Found duplication: عذراً،عذراً');
      }
      if (finalResponse.contains('لاعذرا')) {
        print('❌ Found broken text: لاعذرا');
      }
      if (finalResponse.contains('عذراً،')) {
        print('❌ Found comma issue: عذراً،');
      }

      // Print each character to debug
      print('📝 First 50 characters:');
      for (int i = 0;
          i < (finalResponse.length > 50 ? 50 : finalResponse.length);
          i++) {
        print('  [$i]: "${finalResponse[i]}" (${finalResponse.codeUnitAt(i)})');
      }
    });
  });
}
