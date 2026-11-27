import '../model/chat_message.dart';
import '../model/chat_session.dart';
import 'chatbot_repository.dart';

/// Use case for sending messages and receiving responses
class SendMessageUseCase {
  final ChatbotRepository _repository;

  SendMessageUseCase(this._repository);

  Future<ChatMessage> call({
    required String sessionId,
    required String userMessage,
    required String userId,
  }) async {
    if (userMessage.trim().isEmpty) {
      throw Exception('الرسالة لا يمكن أن تكون فارغة');
    }

    return await _repository.sendMessage(
      sessionId: sessionId,
      userMessage: userMessage,
      userId: userId,
    );
  }
}

/// Use case for streaming messages and receiving word-by-word responses
class SendStreamingMessageUseCase {
  final ChatbotRepository _repository;

  SendStreamingMessageUseCase(this._repository);

  Stream<String> call({
    required String sessionId,
    required String userMessage,
    required String userId,
  }) async* {
    if (userMessage.trim().isEmpty) {
      throw Exception('الرسالة لا يمكن أن تكون فارغة');
    }

    yield* _repository.sendStreamingMessage(
      sessionId: sessionId,
      userMessage: userMessage,
      userId: userId,
    );
  }
}

/// Use case for getting chat history
class GetChatHistoryUseCase {
  final ChatbotRepository _repository;

  GetChatHistoryUseCase(this._repository);

  Future<List<ChatSession>> call(String userId) async {
    return await _repository.getChatHistory(userId);
  }
}

/// Use case for getting a specific chat session
class GetChatSessionUseCase {
  final ChatbotRepository _repository;

  GetChatSessionUseCase(this._repository);

  Future<ChatSession?> call(String sessionId) async {
    return await _repository.getChatSession(sessionId);
  }
}

/// Use case for creating a new chat session
class CreateChatSessionUseCase {
  final ChatbotRepository _repository;

  CreateChatSessionUseCase(this._repository);

  Future<ChatSession> call({required String userId, String? title}) async {
    return await _repository.createChatSession(userId: userId, title: title);
  }
}

/// Use case for saving a chat session
class SaveChatSessionUseCase {
  final ChatbotRepository _repository;

  SaveChatSessionUseCase(this._repository);

  Future<void> call(ChatSession session) async {
    return await _repository.saveChatSession(session);
  }
}

/// Use case for deleting a chat session
class DeleteChatSessionUseCase {
  final ChatbotRepository _repository;

  DeleteChatSessionUseCase(this._repository);

  Future<void> call(String sessionId) async {
    return await _repository.deleteChatSession(sessionId);
  }
}

/// Use case for clearing chat history
class ClearChatHistoryUseCase {
  final ChatbotRepository _repository;

  ClearChatHistoryUseCase(this._repository);

  Future<void> call(String userId) async {
    return await _repository.clearChatHistory(userId);
  }
}

/// Use case for searching messages
class SearchMessagesUseCase {
  final ChatbotRepository _repository;

  SearchMessagesUseCase(this._repository);

  Future<List<ChatMessage>> call({
    required String userId,
    required String query,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    return await _repository.searchMessages(userId: userId, query: query);
  }
}
