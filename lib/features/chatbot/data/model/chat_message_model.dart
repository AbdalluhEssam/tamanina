import '../../data/model/chat_message.dart';

/// Data model for ChatMessage with JSON serialization
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.isUser,
    required super.timestamp,
    super.type = MessageType.text,
    super.metadata,
    super.isLoading = false,
  });

  /// Create from entity
  factory ChatMessageModel.fromEntity(ChatMessage message) {
    return ChatMessageModel(
      id: message.id,
      content: message.content,
      isUser: message.isUser,
      timestamp: message.timestamp,
      type: message.type,
      metadata: message.metadata,
      isLoading: message.isLoading,
    );
  }

  /// Create from JSON
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) =>
            e.toString().split('.').last == (json['type'] as String? ?? 'text'),
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isLoading: json['isLoading'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'metadata': metadata,
      'isLoading': isLoading,
    };
  }

  /// Create from Firestore document
  factory ChatMessageModel.fromFirestore(Map<String, dynamic> doc) {
    return ChatMessageModel.fromJson(doc);
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Convert to entity
  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      content: content,
      isUser: isUser,
      timestamp: timestamp,
      type: type,
      metadata: metadata,
      isLoading: isLoading,
    );
  }

  /// Create copy with updated properties
  @override
  ChatMessageModel copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageType? type,
    Map<String, dynamic>? metadata,
    bool? isLoading,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
