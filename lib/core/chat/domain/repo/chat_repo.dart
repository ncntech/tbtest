import 'package:dartz/dartz.dart';
import 'package:nasmotives/core/chat/domain/entity/chat_failure.dart';
import 'package:nasmotives/core/chat/domain/entity/chat_message.dart';
import 'package:nasmotives/core/chat/domain/entity/chat_session.dart';
import 'package:nasmotives/core/chat/domain/entity/nastech_config.dart';

abstract class ChatRepo {
  Future<Either<ChatFailure, Stream<String>>> sendMessage({
    required List<ChatMessage> history,
    required String userMessage,
    required NasTechConfig config,
  });

  Future<Either<ChatFailure, List<ChatSession>>> getSessions();

  Future<Either<ChatFailure, ChatSession>> createSession({String? title});

  Future<Either<ChatFailure, Unit>> deleteSession(String sessionId);

  Future<Either<ChatFailure, Unit>> saveSession(ChatSession session);

  Future<Either<ChatFailure, bool>> testConnection(NasTechConfig config);

  NasTechConfig? get savedConfig;

  Future<void> saveConfig(NasTechConfig config);
}
