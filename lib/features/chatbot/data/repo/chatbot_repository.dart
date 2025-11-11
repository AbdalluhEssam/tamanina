import '../model/chat_message.dart';
import '../model/chat_session.dart';

/// Repository interface for chatbot data operations
abstract class ChatbotRepository {
  /// Send a message and get AI response
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required String userMessage,
    required String userId,
  });

  /// Send a message and get streaming AI response (word by word)
  Stream<String> sendStreamingMessage({
    required String sessionId,
    required String userMessage,
    required String userId,
  });

  /// Get chat history for a user
  Future<List<ChatSession>> getChatHistory(String userId);

  /// Get a specific chat session
  Future<ChatSession?> getChatSession(String sessionId);

  /// Save a chat session
  Future<void> saveChatSession(ChatSession session);

  /// Delete a chat session
  Future<void> deleteChatSession(String sessionId);

  /// Clear all chat history for a user
  Future<void> clearChatHistory(String userId);

  /// Create a new chat session
  Future<ChatSession> createChatSession({
    required String userId,
    String? title,
  });

  /// Update chat session
  Future<void> updateChatSession(ChatSession session);

  /// Search messages in chat history
  Future<List<ChatMessage>> searchMessages({
    required String userId,
    required String query,
  });
}
