import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../domain/entities/chat_message.dart';

/// Service for Islamic AI responses using ChatGPT API with offline fallback
class IslamicAiService {
  /// Store conversation context
  final List<Map<String, String>> _conversationHistory = [];

  /// Current model being used
  final String model;

  /// Islamic context prompt for ChatGPT
  static const String _islamicSystemPrompt =
      '''أنت مساعد ذكي إسلامي متخصص في تقديم إجابات دقيقة ومفيدة حول الدين الإسلامي.

إرشادات مهمة:
- أجب بالعربية دائماً وبوضوح تام
- اعتمد على القرآن الكريم والسنة النبوية الصحيحة
- أجب على السؤال المحدد مباشرة قبل إعطاء معلومات عامة
- اذكر الدليل من القرآن أو الحديث عند الإمكان مع ذكر المرجع
- كن لطيفاً ومتفهماً ولكن واضحاً في الإجابة
- إذا لم تكن متأكداً من إجابة فقل "والله أعلم" وأشر إلى ضرورة سؤال أهل العلم
- في المسائل الخلافية، اذكر الآراء الأساسية مع الدليل
- احترم جميع المذاهب الإسلامية المعتبرة
- قدم النصائح العملية والتطبيقية
- استخدم لغة واضحة ومفهومة
- لا تعطِ ردود عامة، بل أجب على السؤال المطروح مباشرة

موضوعاتك: العقيدة، العبادات، المعاملات، الأخلاق، السيرة النبوية، التفسير، الحديث، الفقه الإسلامي، الزواج، الطلاق، تعدد الزوجات، الميراث، الحلال والحرام.

تذكر: أجب على السؤال المحدد أولاً، ثم أضف المعلومات الإضافية إذا لزم الأمر.''';

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

      // Try ChatGPT API first, fallback to offline responses
      String response = await _getChatGPTResponse(userMessage) ??
          _getOfflineResponse(userMessage);

      // Add AI response to conversation history
      _conversationHistory.add({
        'role': 'assistant',
        'content': response,
      });

      // Keep conversation history manageable
      if (_conversationHistory.length > ApiConfig.maxConversationHistory) {
        _conversationHistory.removeRange(
            0, _conversationHistory.length - ApiConfig.maxConversationHistory);
      }

      // Stream response word by word for typing effect
      final words = response.split(' ');
      for (int i = 0; i < words.length; i++) {
        await Future.delayed(ApiConfig.streamingDelay);
        if (i == 0) {
          yield words[i];
        } else {
          yield ' ${words[i]}';
        }
      }
    } catch (e) {
      // Fallback to offline response on any error
      final fallbackResponse = _getOfflineResponse(userMessage);
      final words = fallbackResponse.split(' ');
      for (int i = 0; i < words.length; i++) {
        await Future.delayed(ApiConfig.streamingDelay);
        if (i == 0) {
          yield words[i];
        } else {
          yield ' ${words[i]}';
        }
      }
    }
  }

  /// Get response from ChatGPT API with retry mechanism
  Future<String?> _getChatGPTResponse(String userMessage) async {
    for (int attempt = 0; attempt < ApiConfig.maxRetries; attempt++) {
      try {
        // Prepare messages for ChatGPT API
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
            '🔄 Attempting ChatGPT API call (attempt ${attempt + 1}/${ApiConfig.maxRetries})...');
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
                '✅ ChatGPT Response received: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
            return content;
          }
        } else if (response.statusCode == 429) {
          print('⚠️ API Rate limit exceeded, attempt ${attempt + 1}');
          if (attempt < ApiConfig.maxRetries - 1) {
            await Future.delayed(ApiConfig.retryDelay * (attempt + 1));
            continue;
          }
        } else {
          print(
              '❌ ChatGPT API Error: ${response.statusCode} - ${response.body}');
          if (attempt < ApiConfig.maxRetries - 1) {
            await Future.delayed(ApiConfig.retryDelay);
            continue;
          }
        }
      } catch (e) {
        print('🚨 ChatGPT API Exception (attempt ${attempt + 1}): $e');
        if (attempt < ApiConfig.maxRetries - 1) {
          await Future.delayed(ApiConfig.retryDelay);
          continue;
        }
      }
    }

    print(
        '💔 All ChatGPT API attempts failed, falling back to offline response');
    return null;
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

      // Try ChatGPT API first, fallback to offline
      String responseContent = await _getChatGPTResponse(userMessage) ??
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

  /// Get offline Islamic responses - always works without internet
  String _getOfflineResponse(String userMessage) {
    final messageLower = userMessage.toLowerCase();

    // Islamic greetings
    if (messageLower.contains('سلام') ||
        messageLower.contains('السلام') ||
        messageLower.contains('مرحبا') ||
        messageLower.contains('أهلا')) {
      return 'وعليكم السلام ورحمة الله وبركاته\n\nمرحباً بك أخي الكريم، أنا هنا لمساعدتك في الأسئلة الإسلامية. كيف يمكنني خدمتك؟';
    }

    // Prayer related questions
    if (messageLower.contains('صلاة') ||
        messageLower.contains('صلوات') ||
        messageLower.contains('فرض') ||
        messageLower.contains('وضوء')) {
      return 'الصلاة عماد الدين وهي أول ما يحاسب عليه العبد يوم القيامة.\n\nالصلوات الخمس المفروضة هي:\n• الفجر: ركعتان\n• الظهر: أربع ركعات\n• العصر: أربع ركعات\n• المغرب: ثلاث ركعات\n• العشاء: أربع ركعات\n\nقال تعالى: "وأقيموا الصلاة وآتوا الزكاة واركعوا مع الراكعين" البقرة:43';
    }

    // Marriage and polygamy questions - Enhanced
    if (messageLower.contains('زواج') ||
        messageLower.contains('عائلة') ||
        messageLower.contains('تعدد') ||
        messageLower.contains('التعدد') ||
        messageLower.contains('زوجات') ||
        messageLower.contains('أربع') ||
        messageLower.contains('حرام') ||
        messageLower.contains('حلال')) {
      // Specific answer for polygamy questions
      if (messageLower.contains('تعدد') ||
          messageLower.contains('التعدد') ||
          messageLower.contains('زوجات') ||
          messageLower.contains('أربع')) {
        return 'تعدد الزوجات في الإسلام حكم شرعي مباح وليس واجباً أو محرماً.\n\nالأدلة الشرعية:\nقال تعالى: "فانكحوا ما طاب لكم من النساء مثنى وثلاث ورباع فإن خفتم ألا تعدلوا فواحدة" النساء:3\n\nشروط التعدد:\n• القدرة على العدل بين الزوجات\n• القدرة المالية على الإنفاق\n• القدرة الجسدية والنفسية\n• ألا يتجاوز أربع زوجات\n\nقال النبي ﷺ: "من كان له امرأتان فمال إلى إحداهما جاء يوم القيامة وشقه مائل"\n\nحكمة التشريع:\n• حماية المرأة الأرملة والمطلقة\n• زيادة النسل في المجتمع\n• تلبية الحاجات الفطرية بطريقة شرعية\n\nوالله أعلم. يُنصح بمراجعة أهل العلم في هذه المسألة لفهم تفاصيل أكثر.';
      }

      // General marriage guidance
      return 'الزواج في الإسلام رباط مقدس ونصف الدين.\n\nقال تعالى: "ومن آياته أن خلق لكم من أنفسكم أزواجاً لتسكنوا إليها وجعل بينكم مودة ورحمة" الروم:21\n\nمن آداب الأسرة في الإسلام:\n• المعاشرة بالمعروف\n• حسن التربية للأولاد\n• بر الوالدين\n• العدل بين الأولاد\n\nقال النبي ﷺ: "خيركم خيركم لأهله وأنا خيركم لأهلي"';
    }

    // Quran related questions
    if (messageLower.contains('قرآن') ||
        messageLower.contains('تلاوة') ||
        messageLower.contains('حفظ') ||
        messageLower.contains('آية')) {
      return 'القرآن الكريم هو كلام الله المنزل على نبينا محمد صلى الله عليه وسلم.\n\n• يستحب قراءة القرآن يومياً\n• كل حرف بحسنة والحسنة بعشر أمثالها\n• من قرأ القرآن فله بكل حرف حسنة\n\nقال تعالى: "إن هذا القرآن يهدي للتي هي أقوم" الإسراء:9\n\nهل تريد توجيهات حول حفظ القرآن أم تلاوته؟';
    }

    // General Islamic advice - Only for unmatched questions
    return 'بارك الله فيك على سؤالك الكريم.\n\nأجب على سؤالك بالاعتماد على:\n• القرآن الكريم وتفسيره\n• السنة النبوية المطهرة\n• فهم السلف الصالح\n\nقال تعالى: "فاسألوا أهل الذكر إن كنتم لا تعلمون" النحل:43\n\nهل يمكنك إعادة صياغة سؤالك بطريقة أكثر تحديداً لأتمكن من مساعدتك بشكل أفضل؟';
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
