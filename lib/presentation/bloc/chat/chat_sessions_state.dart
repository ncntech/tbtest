import 'package:nasmotives/core/chat/domain/entity/chat_session.dart';

class ChatSessionsState {
  final List<ChatSession> sessions;
  final bool isLoading;

  const ChatSessionsState({
    this.sessions = const [],
    this.isLoading = false,
  });

  factory ChatSessionsState.initial() => const ChatSessionsState();

  ChatSessionsState copyWith({
    List<ChatSession>? sessions,
    bool? isLoading,
  }) {
    return ChatSessionsState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
