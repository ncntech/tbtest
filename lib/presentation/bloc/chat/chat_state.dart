import 'package:nasmotives/core/chat/domain/entity/chat_failure.dart';
import 'package:nasmotives/core/chat/domain/entity/chat_message.dart';
import 'package:nasmotives/core/chat/domain/entity/chat_session.dart';
import 'package:nasmotives/core/chat/domain/entity/nastech_config.dart';

class ChatState {
  final ChatSession? activeSession;
  final bool isSending;
  final bool isStreaming;
  final ChatFailure? failure;
  final NasTechConfig? config;
  final bool isConfigured;

  const ChatState({
    this.activeSession,
    this.isSending = false,
    this.isStreaming = false,
    this.failure,
    this.config,
    this.isConfigured = false,
  });

  List<ChatMessage> get messages => activeSession?.messages ?? [];

  factory ChatState.initial() => const ChatState();

  ChatState copyWith({
    ChatSession? activeSession,
    bool? isSending,
    bool? isStreaming,
    ChatFailure? failure,
    NasTechConfig? config,
    bool? isConfigured,
    bool clearFailure = false,
  }) {
    return ChatState(
      activeSession: activeSession ?? this.activeSession,
      isSending: isSending ?? this.isSending,
      isStreaming: isStreaming ?? this.isStreaming,
      failure: clearFailure ? null : (failure ?? this.failure),
      config: config ?? this.config,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }
}
