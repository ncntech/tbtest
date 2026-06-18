import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nasmotives/core/chat/domain/repo/chat_repo.dart';
import 'package:nasmotives/presentation/bloc/chat/chat_sessions_state.dart';

@LazySingleton()
class ChatSessionsCubit extends Cubit<ChatSessionsState> {
  final ChatRepo _repo;

  ChatSessionsCubit(this._repo) : super(ChatSessionsState.initial()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    emit(state.copyWith(isLoading: true));
    final result = await _repo.getSessions();
    result.fold(
      (_) => emit(state.copyWith(isLoading: false)),
      (sessions) => emit(state.copyWith(sessions: sessions, isLoading: false)),
    );
  }

  Future<void> deleteSession(String sessionId) async {
    await _repo.deleteSession(sessionId);
    await loadSessions();
  }
}
