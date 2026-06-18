import 'package:nasmotives/core/chat/domain/entity/chat_message.dart';
import 'package:nasmotives/core/misc/domain/entity/unique_id.dart';

class ChatSession {
  final UniqueId id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final bool isActive;

  const ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.isActive = false,
  });

  ChatMessage? get lastMessage =>
      messages.isNotEmpty ? messages.last : null;

  int get messageCount => messages.length;

  factory ChatSession.create({String? title}) {
    final now = DateTime.now();
    return ChatSession(
      id: UniqueId.fromValue(now.millisecondsSinceEpoch),
      title: title ?? 'New Chat',
      createdAt: now,
      updatedAt: now,
      messages: [],
      isActive: true,
    );
  }

  ChatSession copyWith({
    String? title,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      isActive: isActive ?? this.isActive,
    );
  }
}
