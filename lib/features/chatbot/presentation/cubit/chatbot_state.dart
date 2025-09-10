import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';

/// States for the chatbot
abstract class ChatbotState extends Equatable {
  const ChatbotState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChatbotInitial extends ChatbotState {}

/// Loading state
class ChatbotLoading extends ChatbotState {}

/// Loaded state with current session
class ChatbotLoaded extends ChatbotState {
  final ChatSession currentSession;
  final List<ChatSession> chatHistory;
  final bool isTyping;
  final String? error;

  const ChatbotLoaded({
    required this.currentSession,
    required this.chatHistory,
    this.isTyping = false,
    this.error,
  });

  @override
  List<Object?> get props => [currentSession, chatHistory, isTyping, error];

  ChatbotLoaded copyWith({
    ChatSession? currentSession,
    List<ChatSession>? chatHistory,
    bool? isTyping,
    String? error,
  }) {
    return ChatbotLoaded(
      currentSession: currentSession ?? this.currentSession,
      chatHistory: chatHistory ?? this.chatHistory,
      isTyping: isTyping ?? this.isTyping,
      error: error,
    );
  }
}

/// Error state
class ChatbotError extends ChatbotState {
  final String message;

  const ChatbotError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Message sending state
class ChatbotSendingMessage extends ChatbotState {
  final ChatSession currentSession;
  final ChatMessage userMessage;

  const ChatbotSendingMessage({
    required this.currentSession,
    required this.userMessage,
  });

  @override
  List<Object?> get props => [currentSession, userMessage];
}

/// Message sent successfully
class ChatbotMessageSent extends ChatbotState {
  final ChatSession updatedSession;
  final ChatMessage aiResponse;

  const ChatbotMessageSent({
    required this.updatedSession,
    required this.aiResponse,
  });

  @override
  List<Object?> get props => [updatedSession, aiResponse];
}

/// Session created state
class ChatbotSessionCreated extends ChatbotState {
  final ChatSession newSession;

  const ChatbotSessionCreated(this.newSession);

  @override
  List<Object?> get props => [newSession];
}

/// History loaded state
class ChatbotHistoryLoaded extends ChatbotState {
  final List<ChatSession> history;

  const ChatbotHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

/// Streaming response state - for typing effect
class ChatbotStreamingResponse extends ChatbotState {
  final ChatSession currentSession;
  final String currentStreamText;
  final bool isComplete;
  final List<ChatSession> chatHistory;

  const ChatbotStreamingResponse({
    required this.currentSession,
    required this.currentStreamText,
    required this.isComplete,
    required this.chatHistory,
  });

  @override
  List<Object?> get props =>
      [currentSession, currentStreamText, isComplete, chatHistory];

  ChatbotStreamingResponse copyWith({
    ChatSession? currentSession,
    String? currentStreamText,
    bool? isComplete,
    List<ChatSession>? chatHistory,
  }) {
    return ChatbotStreamingResponse(
      currentSession: currentSession ?? this.currentSession,
      currentStreamText: currentStreamText ?? this.currentStreamText,
      isComplete: isComplete ?? this.isComplete,
      chatHistory: chatHistory ?? this.chatHistory,
    );
  }
}
