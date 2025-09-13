import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../domain/entities/chat_message.dart';

/// Service for Islamic AI responses using Groq API with offline fallback
class IslamicAiService {
  /// Store conversation context
  final List<Map<String, String>> _conversationHistory = [];

  /// Current model being used
  final String model;
  static const String _islamicSystemPrompt = '''
أنت مساعد إسلامي ذكي اسمه "طمأنينة – Tamanina". 
دورك أن تجيب على الأسئلة الشرعية باختصار (3 أسطر فقط) 
واختم إجابتك دائمًا بعبارة: 
"والله أعلم، ويُفضل الرجوع إلى الأزهر الشريف أو العلماء الموثوقين".
''';
  IslamicAiService({this.model = ApiConfig.defaultModel});

  /// Generate streaming response using ChatGPT API with fallback to offline responses
  Stream<String> generateStreamingResponse({
    required String userMessage,
    required String sessionId,
  }) async* {
    try {
      // Add user message to conversation history
      _conversationHistory.add({
        'role': 'user',
        'content': userMessage,
      });

      // Try to get response from Groq API first
      final apiResponse = await _getGroqStreamingResponse(userMessage);

      if (apiResponse != null && apiResponse.isNotEmpty) {
        // Stream the API response word by word, handling emojis properly
        yield* _streamTextWithEmojis(apiResponse);

        // Add AI response to conversation history
        _conversationHistory.add({
          'role': 'assistant',
          'content': apiResponse,
        });

        // Keep conversation history manageable
        if (_conversationHistory.length >
            ApiConfig.maxConversationHistory * 2) {
          _conversationHistory.removeRange(0, 2);
        }
      } else {
        // Fallback to offline response only if API fails
        print('🔄 API failed, using offline fallback response');
        final offlineResponse = _getOfflineResponse(userMessage);
        yield* _streamTextWithEmojis(offlineResponse);
      }
    } catch (e) {
      print('❌ Error in streaming response: $e');
      // Fallback to offline response in case of error
      final offlineResponse = _getOfflineResponse(userMessage);
      yield* _streamTextWithEmojis(offlineResponse);
    }
  }

  /// Get response from Groq API with retry mechanism
  Future<String?> _getGroqResponse(String userMessage) async {
    // Check if API key is properly configured
    if (ApiConfig.openAIApiKey == 'YOUR_OPENAI_API_KEY_HERE' ||
        ApiConfig.openAIApiKey.isEmpty) {
      print('⚠️ Groq API key not configured properly');
      return null;
    }

    for (int attempt = 0; attempt < ApiConfig.maxRetries; attempt++) {
      try {
        // Prepare messages for Groq API
        final messages = [
          {
            'role': 'system',
            'content': _islamicSystemPrompt,
          }
        ];

        // Add conversation history (limit to manage token usage)
        final recentHistory = _conversationHistory.length >
                ApiConfig.maxConversationHistory
            ? _conversationHistory.sublist(
                _conversationHistory.length - ApiConfig.maxConversationHistory)
            : _conversationHistory;

        messages.addAll(recentHistory);

        final apiUrl =
            '${ApiConfig.openAIBaseUrl}${ApiConfig.chatCompletionsEndpoint}';

        print(
            '� Attempting Groq API call (attempt ${attempt + 1}/${ApiConfig.maxRetries})...');
        print('📝 Request: $userMessage');

        final response = await http
            .post(
              Uri.parse(apiUrl),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${ApiConfig.openAIApiKey}',
                'User-Agent': 'Tamanina-Islamic-App/1.0',
              },
              body: jsonEncode({
                'model': model,
                'messages': messages,
                'max_tokens': ApiConfig.maxTokens,
                'temperature': ApiConfig.temperature,
                'top_p': 0.9,
                'frequency_penalty': 0.1,
                'presence_penalty': 0.1,
              }),
            )
            .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

        print('📡 API Response Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['choices'] != null &&
              data['choices'].isNotEmpty &&
              data['choices'][0]['message'] != null &&
              data['choices'][0]['message']['content'] != null) {
            final content =
                data['choices'][0]['message']['content'].toString().trim();
            print(
                '✅ Groq Response received: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
            return content;
          }
        } else if (response.statusCode == 401) {
          print('❌ API Authentication failed - Invalid API key');
          return null; // Don't retry on auth failure
        } else if (response.statusCode == 429) {
          print('⚠️ API Rate limit exceeded, attempt ${attempt + 1}');
          if (attempt < ApiConfig.maxRetries - 1) {
            await Future.delayed(ApiConfig.retryDelay * (attempt + 1));
            continue;
          }
        } else {
          print('❌ Groq API Error: ${response.statusCode} - ${response.body}');
          if (attempt < ApiConfig.maxRetries - 1) {
            await Future.delayed(ApiConfig.retryDelay);
            continue;
          }
        }
      } catch (e) {
        print('🚨 Groq API Exception (attempt ${attempt + 1}): $e');
        if (attempt < ApiConfig.maxRetries - 1) {
          await Future.delayed(ApiConfig.retryDelay);
          continue;
        }
      }
    }

    print('💔 All Groq API attempts failed, falling back to offline response');
    return null;
  }

  /// Get streaming response from Groq API
  Future<String?> _getGroqStreamingResponse(String userMessage) async {
    // Check if API key is properly configured
    if (ApiConfig.openAIApiKey == 'YOUR_OPENAI_API_KEY_HERE' ||
        ApiConfig.openAIApiKey.isEmpty) {
      print('⚠️ Groq API key not configured for streaming');
      return null;
    }

    try {
      print('🚀 Getting Groq API response for streaming...');

      // Prepare messages for Groq API
      final messages = [
        {
          'role': 'system',
          'content': _islamicSystemPrompt,
        }
      ];

      // Add conversation history (limit to manage token usage)
      final recentHistory = _conversationHistory.length >
              ApiConfig.maxConversationHistory
          ? _conversationHistory.sublist(
              _conversationHistory.length - ApiConfig.maxConversationHistory)
          : _conversationHistory;

      messages.addAll(recentHistory);

      final apiUrl =
          '${ApiConfig.openAIBaseUrl}${ApiConfig.chatCompletionsEndpoint}';

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${ApiConfig.openAIApiKey}',
              'User-Agent': 'Tamanina-Islamic-App/1.0',
            },
            body: jsonEncode({
              'model': model,
              'messages': messages,
              'max_tokens': ApiConfig.maxTokens,
              'temperature': ApiConfig.temperature,
              'top_p': 0.9,
              'frequency_penalty': 0.1,
              'presence_penalty': 0.1,
            }),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null &&
            data['choices'].isNotEmpty &&
            data['choices'][0]['message'] != null &&
            data['choices'][0]['message']['content'] != null) {
          final content =
              data['choices'][0]['message']['content'].toString().trim();
          print('✅ Groq API response received for streaming');
          return content;
        }
      } else if (response.statusCode == 401) {
        print('❌ API Authentication failed - Invalid API key for streaming');
        return null;
      } else {
        print(
            '❌ Groq API streaming error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Groq API streaming failed: $e');
      return null;
    }
    return null;
  }

  /// Stream text with proper emoji handling
  Stream<String> _streamTextWithEmojis(String text) async* {
    // Split by spaces but be careful with emojis and Arabic text
    final words = _smartSplitText(text);
    String currentText = '';

    for (int i = 0; i < words.length; i++) {
      currentText += '${words[i]} ';
      yield currentText.trim();

      // Add realistic typing delay
      await Future.delayed(ApiConfig.streamingDelay);
    }
  }

  /// Smart text splitting that preserves emojis and Arabic text
  List<String> _smartSplitText(String text) {
    final List<String> result = [];
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == ' ') {
        if (buffer.isNotEmpty) {
          result.add(buffer.toString());
          buffer.clear();
        }
      } else if (char == '\n') {
        if (buffer.isNotEmpty) {
          result.add(buffer.toString());
          buffer.clear();
        }
        result.add('\n');
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      result.add(buffer.toString());
    }

    return result;
  }

  /// Generate single response (non-streaming) - for backward compatibility
  Future<ChatMessage> generateResponse({
    required String userMessage,
    required String sessionId,
  }) async {
    try {
      // Add user message to conversation history
      _conversationHistory.add({
        'role': 'user',
        'content': userMessage,
      });

      // Try Groq API first, fallback to offline
      String responseContent = await _getGroqResponse(userMessage) ??
          _getOfflineResponse(userMessage);

      // Add AI response to conversation history
      _conversationHistory.add({
        'role': 'assistant',
        'content': responseContent,
      });

      // Keep conversation history manageable
      if (_conversationHistory.length > ApiConfig.maxConversationHistory) {
        _conversationHistory.removeRange(
            0, _conversationHistory.length - ApiConfig.maxConversationHistory);
      }

      // Determine message type based on content
      final messageType = _determineMessageType(responseContent);

      return ChatMessage.assistant(
        id: _generateMessageId(),
        content: responseContent,
        type: messageType,
      );
    } catch (e) {
      // Fallback response
      final fallbackResponse = _getOfflineResponse(userMessage);
      return ChatMessage.assistant(
        id: _generateMessageId(),
        content: fallbackResponse,
        type: MessageType.text,
      );
    }
  }

  /// Get offline Islamic responses - Simple fallback when API is unavailable
  String _getOfflineResponse(String userMessage) {
    final messageLower = userMessage.toLowerCase().trim();

    // Islamic greetings - Only for pure greetings, not questions
    if ((messageLower == 'سلام' ||
            messageLower == 'السلام عليكم' ||
            messageLower == 'السلام عليكم ورحمة الله وبركاته' ||
            messageLower == 'مرحبا' ||
            messageLower == 'مرحباً' ||
            messageLower == 'أهلا' ||
            messageLower == 'أهلاً' ||
            messageLower == 'صباح الخير' ||
            messageLower == 'مساء الخير') &&
        !messageLower.contains('؟') &&
        !messageLower.contains('كيف') &&
        !messageLower.contains('ما') &&
        !messageLower.contains('هل')) {
      return 'وعليكم السلام ورحمة الله وبركاته\n\nأهلاً وسهلاً بك، أخي الكريم. أنا مساعد إسلامي هنا لمساعدتك في أسئلتك الدينية.\n\nيمكنني مساعدتك في:\n• أسئلة القرآن والتفسير\n• الأحاديث النبوية\n• أحكام الفقه والعبادات\n• الأخلاق الإسلامية\n\nما الذي تود أن تسأل عنه؟';
    }

    // For any other question when API is unavailable
    return 'عذراً، لا يمكنني الإجابة على سؤالك بدقة في الوقت الحالي.\n\nأحتاج للاتصال بقاعدة المعرفة الإسلامية الشاملة للحصول على إجابة دقيقة وموثوقة.\n\nيرجى:\n• التأكد من اتصالك بالإنترنت\n• المحاولة مرة أخرى\n\nأعتذر عن الإزعاج وأتطلع لمساعدتك قريباً إن شاء الله.';
  }

  /// Determine message type based on content
  MessageType _determineMessageType(String content) {
    final contentLower = content.toLowerCase();

    if (contentLower.contains('قال الله') ||
        contentLower.contains('قال تعالى') ||
        contentLower.contains('في كتاب الله') ||
        contentLower.contains('آية') ||
        contentLower.contains('سورة')) {
      return MessageType.quran;
    }

    if (contentLower.contains('قال رسول الله') ||
        contentLower.contains('عن النبي') ||
        contentLower.contains('حديث') ||
        contentLower.contains('صحيح البخاري') ||
        contentLower.contains('صحيح مسلم')) {
      return MessageType.hadith;
    }

    if (contentLower.contains('دعاء') ||
        contentLower.contains('اللهم') ||
        contentLower.contains('ادعية')) {
      return MessageType.dua;
    }

    if (contentLower.contains('أخلاق') ||
        contentLower.contains('تعليم') ||
        contentLower.contains('حكم') ||
        contentLower.contains('فقه')) {
      return MessageType.teaching;
    }

    return MessageType.text;
  }

  /// Generate unique message ID
  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  /// Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }
}
