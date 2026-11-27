import 'package:equatable/equatable.dart';

/// Represents a chat message in the Islamic chatbot conversation
class ChatMessage extends Equatable {
  /// Unique identifier for the message
  final String id;

  /// The content/text of the message
  final String content;

  /// Whether the message is from the user or assistant
  final bool isUser;

  /// Timestamp when the message was created
  final DateTime timestamp;

  /// Optional type for special message formatting (quran, hadith, etc.)
  final MessageType type;

  /// Optional metadata for special content (verse reference, hadith source, etc.)
  final Map<String, dynamic>? metadata;

  /// Loading state for assistant messages
  final bool isLoading;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
    this.metadata,
    this.isLoading = false,
  });

  /// Create a user message
  factory ChatMessage.user({
    required String id,
    required String content,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      isUser: true,
      timestamp: timestamp ?? DateTime.now(),
      type: MessageType.text,
    );
  }

  /// Create an assistant message
  factory ChatMessage.assistant({
    required String id,
    required String content,
    DateTime? timestamp,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
    bool isLoading = false,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      isUser: false,
      timestamp: timestamp ?? DateTime.now(),
      type: type,
      metadata: metadata,
      isLoading: isLoading,
    );
  }

  /// Create a loading message placeholder
  factory ChatMessage.loading({required String id}) {
    return ChatMessage(
      id: id,
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.text,
      isLoading: true,
    );
  }

  /// Create a copy with updated properties
  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageType? type,
    Map<String, dynamic>? metadata,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    isUser,
    timestamp,
    type,
    metadata,
    isLoading,
  ];
}

/// Types of messages for special formatting
enum MessageType {
  /// Regular text message
  text,

  /// Quranic verse
  quran,

  /// Hadith/Sunnah reference
  hadith,

  /// Prayer/Dua content
  dua,

  /// Islamic teaching or advice
  teaching,

  /// Error message
  error,

  /// Greeting message
  greeting,
}
