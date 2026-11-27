import '../../data/model/chat_session.dart';
import '../../data/model/chat_message.dart';
import 'chat_message_model.dart';

/// Data model for ChatSession with JSON serialization
class ChatSessionModel extends ChatSession {
  const ChatSessionModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.messages,
    required super.createdAt,
    required super.updatedAt,
    super.isActive = true,
    super.metadata,
  });

  /// Create from entity
  factory ChatSessionModel.fromEntity(ChatSession session) {
    return ChatSessionModel(
      id: session.id,
      userId: session.userId,
      title: session.title,
      messages: session.messages,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      isActive: session.isActive,
      metadata: session.metadata,
    );
  }

  /// Create from JSON
  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map(
                (msg) => ChatMessageModel.fromJson(msg as Map<String, dynamic>),
              )
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'messages': messages
          .map((msg) => ChatMessageModel.fromEntity(msg).toJson())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  /// Create from Firestore document
  factory ChatSessionModel.fromFirestore(Map<String, dynamic> doc) {
    return ChatSessionModel.fromJson(doc);
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Convert to entity
  ChatSession toEntity() {
    return ChatSession(
      id: id,
      userId: userId,
      title: title,
      messages: messages,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      metadata: metadata,
    );
  }

  /// Create copy with updated properties
  @override
  ChatSessionModel copyWith({
    String? id,
    String? userId,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return ChatSessionModel(
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
}
