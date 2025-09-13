import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/usecases/chatbot_usecases.dart';
import 'chatbot_state.dart';

/// Cubit for managing chatbot state and interactions
class ChatbotCubit extends Cubit<ChatbotState> {
  final SendMessageUseCase _sendMessageUseCase;
  final SendStreamingMessageUseCase _sendStreamingMessageUseCase;
  final GetChatHistoryUseCase _getChatHistoryUseCase;
  final GetChatSessionUseCase _getChatSessionUseCase;
  final CreateChatSessionUseCase _createChatSessionUseCase;
  final SaveChatSessionUseCase _saveChatSessionUseCase;
  final DeleteChatSessionUseCase _deleteChatSessionUseCase;
  final ClearChatHistoryUseCase _clearChatHistoryUseCase;
  final SearchMessagesUseCase _searchMessagesUseCase;

  ChatbotCubit({
    required SendMessageUseCase sendMessageUseCase,
    required SendStreamingMessageUseCase sendStreamingMessageUseCase,
    required GetChatHistoryUseCase getChatHistoryUseCase,
    required GetChatSessionUseCase getChatSessionUseCase,
    required CreateChatSessionUseCase createChatSessionUseCase,
    required SaveChatSessionUseCase saveChatSessionUseCase,
    required DeleteChatSessionUseCase deleteChatSessionUseCase,
    required ClearChatHistoryUseCase clearChatHistoryUseCase,
    required SearchMessagesUseCase searchMessagesUseCase,
  })  : _sendMessageUseCase = sendMessageUseCase,
        _sendStreamingMessageUseCase = sendStreamingMessageUseCase,
        _getChatHistoryUseCase = getChatHistoryUseCase,
        _getChatSessionUseCase = getChatSessionUseCase,
        _createChatSessionUseCase = createChatSessionUseCase,
        _saveChatSessionUseCase = saveChatSessionUseCase,
        _deleteChatSessionUseCase = deleteChatSessionUseCase,
        _clearChatHistoryUseCase = clearChatHistoryUseCase,
        _searchMessagesUseCase = searchMessagesUseCase,
        super(ChatbotInitial());

  String? _currentUserId;
  ChatSession? _currentSession;
  List<ChatSession> _chatHistory = [];
  StreamSubscription<String>? _streamingSubscription;
  String _lastStreamingText = '';
  bool _awaitingFinalize = false;

  /// Initialize chatbot with user ID
  Future<void> initialize(String userId) async {
    try {
      emit(ChatbotLoading());
      _currentUserId = userId;

      // Load chat history
      _chatHistory = await _getChatHistoryUseCase(userId);

      // If no active session, create a new one
      if (_chatHistory.isEmpty) {
        await _createNewSession();
      } else {
        // Load the most recent session
        _currentSession = _chatHistory.first;
        emit(ChatbotLoaded(
          currentSession: _currentSession!,
          chatHistory: _chatHistory,
        ));
      }
    } catch (e) {
      emit(ChatbotError('فشل في تهيئة المساعد الذكي: ${e.toString()}'));
    }
  }

  /// Send a message with streaming response (word-by-word typing effect)
  Future<void> sendStreamingMessage(String messageText) async {
    if (_currentSession == null || _currentUserId == null) {
      emit(const ChatbotError('لم يتم تهيئة الجلسة بشكل صحيح'));
      return;
    }

    if (messageText.trim().isEmpty) {
      return;
    }

    try {
      // Create user message
      final userMessage = ChatMessage.user(
        id: _generateMessageId(),
        content: messageText.trim(),
      );

      // Add user message to session
      _currentSession = _currentSession!.addMessage(userMessage);

      // Start streaming response
      String streamingText = '';

      _streamingSubscription?.cancel();
      _streamingSubscription = _sendStreamingMessageUseCase(
        sessionId: _currentSession!.id,
        userMessage: messageText.trim(),
        userId: _currentUserId!,
      ).listen(
        (chunk) {
          // chunk from repository is cumulative; use it directly to avoid duplication
          streamingText = chunk;
          _lastStreamingText = streamingText;
          emit(ChatbotStreamingResponse(
            currentSession: _currentSession!,
            currentStreamText: streamingText,
            isComplete: false,
            chatHistory: _chatHistory,
          ));
        },
        onDone: () async {
          // Mark complete but keep streaming UI until typing animation finishes
          _awaitingFinalize = true;
          emit(ChatbotStreamingResponse(
            currentSession: _currentSession!,
            currentStreamText: streamingText,
            isComplete: true,
            chatHistory: _chatHistory,
          ));
        },
        onError: (error) {
          final message = error?.toString() ?? 'فشل في إرسال الرسالة.';
          emit(ChatbotLoaded(
            currentSession: _currentSession!,
            chatHistory: _chatHistory,
            isTyping: false,
            error: message,
          ));
        },
      );

      // Show initial streaming state with user message
      emit(ChatbotStreamingResponse(
        currentSession: _currentSession!,
        currentStreamText: '',
        isComplete: false,
        chatHistory: _chatHistory,
      ));
    } catch (e) {
      emit(ChatbotLoaded(
        currentSession: _currentSession!,
        chatHistory: _chatHistory,
        isTyping: false,
        error: 'فشل في إرسال الرسالة: ${e.toString()}',
      ));
    }
  }

  /// Finalize streaming after typing animation completes in UI
  void finalizeStreaming() {
    if (!_awaitingFinalize ||
        _lastStreamingText.isEmpty ||
        _currentSession == null) return;

    final aiMessage = ChatMessage.assistant(
      id: _generateMessageId(),
      content: _lastStreamingText,
      type: _determineMessageType(_lastStreamingText),
    );

    _currentSession = _currentSession!.addMessage(aiMessage);
    _updateChatHistory(_currentSession!);

    _awaitingFinalize = false;
    _lastStreamingText = '';

    emit(ChatbotLoaded(
      currentSession: _currentSession!,
      chatHistory: _chatHistory,
      isTyping: false,
    ));
  }

  /// Create a new chat session
  Future<void> createNewSession() async {
    await _createNewSession();
  }

  /// Switch to a different chat session
  Future<void> switchToSession(String sessionId) async {
    try {
      final session = await _getChatSessionUseCase(sessionId);
      if (session != null) {
        _currentSession = session;
        emit(ChatbotLoaded(
          currentSession: _currentSession!,
          chatHistory: _chatHistory,
        ));
      }
    } catch (e) {
      emit(ChatbotError('فشل في تحميل الجلسة: ${e.toString()}'));
    }
  }

  /// Delete a chat session
  Future<void> deleteSession(String sessionId) async {
    try {
      await _deleteChatSessionUseCase(sessionId);
      _chatHistory.removeWhere((session) => session.id == sessionId);

      // If deleted session was current, create new session
      if (_currentSession?.id == sessionId) {
        if (_chatHistory.isNotEmpty) {
          _currentSession = _chatHistory.first;
        } else {
          await _createNewSession();
          return;
        }
      }

      if (_currentSession != null) {
        emit(ChatbotLoaded(
          currentSession: _currentSession!,
          chatHistory: _chatHistory,
        ));
      }
    } catch (e) {
      emit(ChatbotError('فشل في حذف الجلسة: ${e.toString()}'));
    }
  }

  /// Clear all chat history
  Future<void> clearHistory() async {
    if (_currentUserId == null) return;

    try {
      await _clearChatHistoryUseCase(_currentUserId!);
      _chatHistory.clear();
      await _createNewSession();
    } catch (e) {
      emit(ChatbotError('فشل في مسح التاريخ: ${e.toString()}'));
    }
  }

  /// Search messages
  Future<List<ChatMessage>> searchMessages(String query) async {
    if (_currentUserId == null) return [];

    try {
      return await _searchMessagesUseCase(
        userId: _currentUserId!,
        query: query,
      );
    } catch (e) {
      return [];
    }
  }

  /// Get current session
  ChatSession? get currentSession => _currentSession;

  /// Get chat history
  List<ChatSession> get chatHistory => List.unmodifiable(_chatHistory);

  /// Clear any error state
  void clearError() {
    if (state is ChatbotLoaded && _currentSession != null) {
      final currentState = state as ChatbotLoaded;
      emit(currentState.copyWith(error: null));
    }
  }

  /// Non-streaming send (fallback or testing). Uses _sendMessageUseCase.
  Future<void> sendMessage(String messageText) async {
    if (_currentSession == null || _currentUserId == null) {
      emit(const ChatbotError('لم يتم تهيئة الجلسة بشكل صحيح'));
      return;
    }

    final text = messageText.trim();
    if (text.isEmpty) return;

    try {
      // Add user message to in-memory session
      final userMessage = ChatMessage.user(
        id: _generateMessageId(),
        content: text,
      );
      _currentSession = _currentSession!.addMessage(userMessage);

      emit(ChatbotLoaded(
        currentSession: _currentSession!,
        chatHistory: _chatHistory,
        isTyping: true,
      ));

      // Use non-streaming use case
      final aiMessage = await _sendMessageUseCase(
        sessionId: _currentSession!.id,
        userMessage: text,
        userId: _currentUserId!,
      );

      _currentSession = _currentSession!.addMessage(aiMessage);
      _updateChatHistory(_currentSession!);

      emit(ChatbotLoaded(
        currentSession: _currentSession!,
        chatHistory: _chatHistory,
        isTyping: false,
      ));
    } catch (e) {
      emit(ChatbotLoaded(
        currentSession: _currentSession!,
        chatHistory: _chatHistory,
        isTyping: false,
        error: 'فشل في إرسال الرسالة: ${e.toString()}',
      ));
    }
  }

  /// Private method to create new session
  Future<void> _createNewSession() async {
    if (_currentUserId == null) return;

    try {
      _currentSession = await _createChatSessionUseCase(
        userId: _currentUserId!,
      );

      _chatHistory.insert(0, _currentSession!);

      emit(ChatbotLoaded(
        currentSession: _currentSession!,
        chatHistory: _chatHistory,
      ));
    } catch (e) {
      emit(ChatbotError('فشل في إنشاء جلسة جديدة: ${e.toString()}'));
    }
  }

  /// Update chat history with latest session
  void _updateChatHistory(ChatSession updatedSession) {
    final index = _chatHistory.indexWhere((s) => s.id == updatedSession.id);
    if (index != -1) {
      _chatHistory[index] = updatedSession;
    } else {
      _chatHistory.insert(0, updatedSession);
    }

    // Sort by updated date, most recent first
    _chatHistory.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
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

  @override
  Future<void> close() {
    // Cancel streaming subscription
    _streamingSubscription?.cancel();

    // Save current session before closing
    if (_currentSession != null) {
      _saveChatSessionUseCase(_currentSession!);
    }
    return super.close();
  }
}
