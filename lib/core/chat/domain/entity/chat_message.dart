import 'package:nasmotives/core/misc/domain/entity/unique_id.dart';

enum ChatRole { user, assistant, system }
enum ChatMessageStatus { sending, sent, streaming, error }

class ChatMessage {
  final UniqueId id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;
  final ChatMessageStatus status;
  final String? sessionId;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    required this.status,
    this.sessionId,
  });

  bool get isUser => role == ChatRole.user;
  bool get isAssistant => role == ChatRole.assistant;
  bool get isStreaming => status == ChatMessageStatus.streaming;
  bool get isError => status == ChatMessageStatus.error;

  ChatMessage copyWith({
    String? content,
    ChatMessageStatus? status,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      status: status ?? this.status,
      sessionId: sessionId,
    );
  }

  factory ChatMessage.user({required String content, String? sessionId}) {
    return ChatMessage(
      id: UniqueId.fromValue(DateTime.now().microsecondsSinceEpoch),
      role: ChatRole.user,
      content: content,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.sending,
      sessionId: sessionId,
    );
  }

  factory ChatMessage.assistantStreaming({String? sessionId}) {
    return ChatMessage(
      id: UniqueId.fromValue(DateTime.now().microsecondsSinceEpoch + 1),
      role: ChatRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      status: ChatMessageStatus.streaming,
      sessionId: sessionId,
    );
  }
}
