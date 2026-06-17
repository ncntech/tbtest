import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nasmotives/core/chat/domain/entity/chat_message.dart';
import 'package:nasmotives/core/chat/domain/entity/chat_session.dart';
import 'package:nasmotives/core/chat/domain/entity/nastech_config.dart';
import 'package:nasmotives/core/chat/domain/repo/chat_repo.dart';
import 'package:nasmotives/presentation/bloc/chat/chat_state.dart';

@LazySingleton()
class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _repo;
  StreamSubscription<String>? _streamSub;

  ChatCubit(this._repo) : super(ChatState.initial()) {
    _init();
  }

  void _init() {
    final config = _repo.savedConfig;
    emit(state.copyWith(
      config: config ?? NasTechConfig.local(),
      isConfigured: config != null,
    ));
    startNewSession();
  }

  void startNewSession({String? title}) {
    final session = ChatSession.create(title: title);
    emit(state.copyWith(activeSession: session, clearFailure: true));
  }

  void loadSession(ChatSession session) {
    emit(state.copyWith(activeSession: session, clearFailure: true));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isSending || state.isStreaming) return;

    final config = state.config ?? NasTechConfig.local();
    final session = state.activeSession ?? ChatSession.create();

    final userMsg = ChatMessage.user(
      content: text.trim(),
      sessionId: session.id.value.toString(),
    );

    final assistantMsg = ChatMessage.assistantStreaming(
      sessionId: session.id.value.toString(),
    );

    final updatedHistory = [...session.messages, userMsg];
    var updatedSession = session.copyWith(
      messages: [...updatedHistory, assistantMsg],
      updatedAt: DateTime.now(),
      title: session.messageCount == 0 ? _extractTitle(text) : null,
    );

    emit(state.copyWith(
      activeSession: updatedSession,
      isSending: true,
      clearFailure: true,
    ));

    final failureOrStream = await _repo.sendMessage(
      history: session.messages,
      userMessage: text.trim(),
      config: config,
    );

    failureOrStream.fold(
      (failure) {
        final errorMsg = assistantMsg.copyWith(
          content: failure.message,
          status: ChatMessageStatus.error,
        );
        final msgs = [...updatedHistory, errorMsg];
        emit(state.copyWith(
          activeSession: updatedSession.copyWith(messages: msgs),
          isSending: false,
          failure: failure,
        ));
      },
      (stream) {
        emit(state.copyWith(isSending: false, isStreaming: true));
        String accumulated = '';
        _streamSub = stream.listen(
          (token) {
            accumulated += token;
            final streamingMsg = assistantMsg.copyWith(
              content: accumulated,
              status: ChatMessageStatus.streaming,
            );
            final msgs = [...updatedHistory, streamingMsg];
            final currentSession = state.activeSession!;
            emit(state.copyWith(
              activeSession: currentSession.copyWith(
                messages: msgs,
                updatedAt: DateTime.now(),
              ),
            ));
          },
          onDone: () {
            final finalMsg = assistantMsg.copyWith(
              content: accumulated,
              status: ChatMessageStatus.sent,
            );
            final msgs = [...updatedHistory, finalMsg];
            final finalSession = state.activeSession!.copyWith(
              messages: msgs,
              updatedAt: DateTime.now(),
            );
            emit(state.copyWith(
              activeSession: finalSession,
              isStreaming: false,
            ));
            _repo.saveSession(finalSession);
          },
          onError: (_) {
            final errorMsg = assistantMsg.copyWith(
              content: accumulated.isEmpty ? 'Stream error.' : accumulated,
              status: ChatMessageStatus.error,
            );
            final msgs = [...updatedHistory, errorMsg];
            emit(state.copyWith(
              activeSession: state.activeSession!.copyWith(messages: msgs),
              isStreaming: false,
            ));
          },
        );
      },
    );
  }

  void stopStreaming() {
    _streamSub?.cancel();
    _streamSub = null;
    emit(state.copyWith(isStreaming: false, isSending: false));
  }

  void updateConfig(NasTechConfig config) {
    _repo.saveConfig(config);
    emit(state.copyWith(config: config, isConfigured: true));
  }

  String _extractTitle(String msg) {
    final words = msg.trim().split(' ');
    if (words.length <= 5) return msg.trim();
    return '${words.take(5).join(' ')}…';
  }

  @override
  Future<void> close() {
    _streamSub?.cancel();
    return super.close();
  }
}
