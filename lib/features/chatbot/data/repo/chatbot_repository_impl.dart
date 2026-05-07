import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/chat_message.dart';
import '../model/chat_session.dart';
import 'chatbot_repository.dart';
import '../model/chat_session_model.dart';
import '../services/islamic_ai_service.dart';

/// Implementation of ChatbotRepository using SharedPreferences for local storage
/// In production, this would use Firebase Firestore or another cloud database
class ChatbotRepositoryImpl implements ChatbotRepository {
  final SharedPreferences _sharedPreferences;
  final IslamicAiService _aiService;

  static const String _sessionsKey = 'chat_sessions';
  static const String _currentSessionKey = 'current_session_id';

  ChatbotRepositoryImpl({
    required SharedPreferences sharedPreferences,
    required IslamicAiService aiService,
  })  : _sharedPreferences = sharedPreferences,
        _aiService = aiService;

  @override
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required String userMessage,
    required String userId,
  }) async {
    try {
      // Add user message to session first
      final userMsg = ChatMessage.user(
        id: _generateMessageId(),
        content: userMessage,
      );

      await _addMessageToSession(sessionId, userMsg);

      // Generate AI response
      final aiResponse = await _aiService.generateResponse(
        userMessage: userMessage,
        sessionId: sessionId,
      );

      // Add AI response to session
      await _addMessageToSession(sessionId, aiResponse);

      return aiResponse;
    } catch (e) {
      // Rethrow so higher layers (cubit) can display a meaningful message
      throw Exception(e.toString());
    }
  }

  @override
  Stream<String> sendStreamingMessage({
    required String sessionId,
    required String userMessage,
    required String userId,
  }) async* {
    try {
      // Persist user message so storage stays in sync with UI
      final userMsg = ChatMessage.user(
        id: _generateMessageId(),
        content: userMessage,
      );
      await _addMessageToSession(sessionId, userMsg);

      // Get streaming response
      String fullResponse = '';
      bool hasError = false;

      await for (final chunk in _aiService.generateStreamingResponse(
        userMessage: userMessage,
        sessionId: sessionId,
      )) {
        // Check if chunk contains error message
        if (chunk.contains('Exception:') || chunk.contains('Error:')) {
          hasError = true;
          yield 'عذراً، حدث خطأ في الاتصال. سأحاول الإجابة من المعلومات المحفوظة...';
          break;
        }

        // Service yields cumulative text; propagate as-is and track latest only
        fullResponse = chunk;
        yield chunk;
      }

      // After streaming is complete, save the full response to session
      if (fullResponse.isNotEmpty && !hasError) {
        final aiResponse = ChatMessage.assistant(
          id: _generateMessageId(),
          content: fullResponse,
          type: _determineMessageType(fullResponse),
        );

        await _addMessageToSession(sessionId, aiResponse);
      }
    } catch (e) {
      // Provide user-friendly error message in Arabic
      yield 'عذراً، حدث خطأ في النظام. يرجى المحاولة مرة أخرى.';
    }
  }

  @override
  Future<List<ChatSession>> getChatHistory(String userId) async {
    try {
      final sessionsJson = _sharedPreferences.getString(_sessionsKey);
      if (sessionsJson == null) return [];

      final sessionsList = json.decode(sessionsJson) as List<dynamic>;
      final sessions = sessionsList
          .map((sessionData) =>
              ChatSessionModel.fromJson(sessionData as Map<String, dynamic>))
          .where((session) => session.userId == userId)
          .map((sessionModel) => sessionModel.toEntity())
          .toList();

      // Sort by updated date, most recent first
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return sessions;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ChatSession?> getChatSession(String sessionId) async {
    try {
      final sessionsJson = _sharedPreferences.getString(_sessionsKey);
      if (sessionsJson == null) return null;

      final sessionsList = json.decode(sessionsJson) as List<dynamic>;
      final sessionData = sessionsList.firstWhere(
        (session) => session['id'] == sessionId,
        orElse: () => null,
      );

      if (sessionData == null) return null;

      final sessionModel =
          ChatSessionModel.fromJson(sessionData as Map<String, dynamic>);
      return sessionModel.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveChatSession(ChatSession session) async {
    try {
      final sessionModel = ChatSessionModel.fromEntity(session);
      final sessionsJson = _sharedPreferences.getString(_sessionsKey) ?? '[]';
      final sessionsList = json.decode(sessionsJson) as List<dynamic>;

      // Remove existing session with same ID
      sessionsList.removeWhere((s) => s['id'] == session.id);

      // Add updated session
      sessionsList.add(sessionModel.toJson());

      // Save back to SharedPreferences
      await _sharedPreferences.setString(
          _sessionsKey, json.encode(sessionsList));
    } catch (e) {
      throw Exception('فشل في حفظ جلسة المحادثة');
    }
  }

  @override
  Future<void> deleteChatSession(String sessionId) async {
    try {
      final sessionsJson = _sharedPreferences.getString(_sessionsKey);
      if (sessionsJson == null) return;

      final sessionsList = json.decode(sessionsJson) as List<dynamic>;
      sessionsList.removeWhere((session) => session['id'] == sessionId);

      await _sharedPreferences.setString(
          _sessionsKey, json.encode(sessionsList));

      // Clear current session if it's the deleted one
      final currentSessionId = _sharedPreferences.getString(_currentSessionKey);
      if (currentSessionId == sessionId) {
        await _sharedPreferences.remove(_currentSessionKey);
      }
    } catch (e) {
      throw Exception('فشل في حذف جلسة المحادثة');
    }
  }

  @override
  Future<void> clearChatHistory(String userId) async {
    try {
      final sessionsJson = _sharedPreferences.getString(_sessionsKey);
      if (sessionsJson == null) return;

      final sessionsList = json.decode(sessionsJson) as List<dynamic>;
      sessionsList.removeWhere((session) => session['userId'] == userId);

      await _sharedPreferences.setString(
          _sessionsKey, json.encode(sessionsList));
      await _sharedPreferences.remove(_currentSessionKey);
    } catch (e) {
      throw Exception('فشل في مسح تاريخ المحادثات');
    }
  }

  @override
  Future<ChatSession> createChatSession({
    required String userId,
    String? title,
  }) async {
    try {
      final sessionId = _generateSessionId();
      final session = ChatSession.create(
        id: sessionId,
        userId: userId,
        title: title ?? 'محادثة جديدة',
      );

      await saveChatSession(session);

      // Set as current session
      await _sharedPreferences.setString(_currentSessionKey, sessionId);

      // Add greeting message
      final greetingMessage = ChatMessage.assistant(
        id: _generateMessageId(),
        content: 'السلام عليكم ورحمة الله وبركاته 🌙\n\n'
            'مرحباً بك في تطبيق "طمأنينة – Tamanina"، المساعد الإسلامي الذكي.\n\n'
            'يمكنني مساعدتك في:\n'
            '• القرآن الكريم وتفسيره\n'
            '• الأحاديث النبوية\n'
            '• أحكام الصلاة والعبادات\n'
            '• الفقه والمعاملات\n'
            '• الأخلاق والأدعية والأذكار\n\n'
            'كيف يمكنني خدمتك اليوم؟',
        type: MessageType.greeting,
      );

      final updatedSession = session.addMessage(greetingMessage);
      await saveChatSession(updatedSession);

      return updatedSession;
    } catch (e) {
      throw Exception('فشل في إنشاء جلسة محادثة جديدة');
    }
  }

  @override
  Future<void> updateChatSession(ChatSession session) async {
    await saveChatSession(session);
  }

  @override
  Future<List<ChatMessage>> searchMessages({
    required String userId,
    required String query,
  }) async {
    try {
      final sessions = await getChatHistory(userId);
      final allMessages = <ChatMessage>[];

      for (final session in sessions) {
        allMessages.addAll(session.messages);
      }

      // Simple text search
      final searchResults = allMessages.where((message) {
        return message.content.toLowerCase().contains(query.toLowerCase());
      }).toList();

      // Sort by timestamp, most recent first
      searchResults.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return searchResults;
    } catch (e) {
      return [];
    }
  }

  /// Helper method to add a message to a session
  Future<void> _addMessageToSession(
      String sessionId, ChatMessage message) async {
    final session = await getChatSession(sessionId);
    if (session != null) {
      final updatedSession = session.addMessage(message);
      await saveChatSession(updatedSession);
    }
  }

  /// Generate unique session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// Generate unique message ID
  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  /// Get current session ID
  Future<String?> getCurrentSessionId() async {
    return _sharedPreferences.getString(_currentSessionKey);
  }

  /// Set current session ID
  Future<void> setCurrentSessionId(String sessionId) async {
    await _sharedPreferences.setString(_currentSessionKey, sessionId);
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
}
