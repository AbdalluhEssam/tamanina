import 'package:equatable/equatable.dart';
import 'chat_message.dart';

/// Represents a chat conversation session
class ChatSession extends Equatable {
  /// Unique identifier for the session
  final String id;

  /// User ID (can be anonymous or authenticated user)
  final String userId;

  /// Session title (auto-generated or user-defined)
  final String title;

  /// List of messages in the conversation
  final List<ChatMessage> messages;

  /// When the session was created
  final DateTime createdAt;

  /// Last time the session was updated
  final DateTime updatedAt;

  /// Whether the session is currently active
  final bool isActive;

  /// Optional metadata for the session
  final Map<String, dynamic>? metadata;

  const ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.metadata,
  });

  /// Create a new chat session
  factory ChatSession.create({
    required String id,
    required String userId,
    String? title,
    List<ChatMessage>? messages,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return ChatSession(
      id: id,
      userId: userId,
      title: title ?? 'محادثة جديدة',
      messages: messages ?? [],
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );
  }

  /// Add a message to the session
  ChatSession addMessage(ChatMessage message) {
    return copyWith(
      messages: [...messages, message],
      updatedAt: DateTime.now(),
    );
  }

  /// Update a specific message
  ChatSession updateMessage(String messageId, ChatMessage updatedMessage) {
    final updatedMessages = messages.map((msg) {
      return msg.id == messageId ? updatedMessage : msg;
    }).toList();

    return copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove a message from the session
  ChatSession removeMessage(String messageId) {
    final updatedMessages =
        messages.where((msg) => msg.id != messageId).toList();

    return copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
  }

  /// Clear all messages
  ChatSession clearMessages() {
    return copyWith(
      messages: [],
      updatedAt: DateTime.now(),
    );
  }

  /// Get the last message in the conversation
  ChatMessage? get lastMessage {
    return messages.isNotEmpty ? messages.last : null;
  }

  /// Check if session has any messages
  bool get hasMessages => messages.isNotEmpty;

  /// Get message count
  int get messageCount => messages.length;

  /// Create a copy with updated properties
  ChatSession copyWith({
    String? id,
    String? userId,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        messages,
        createdAt,
        updatedAt,
        isActive,
        metadata,
      ];
}
