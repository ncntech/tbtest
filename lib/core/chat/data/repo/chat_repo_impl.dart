import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:nasmotives/core/chat/data/source/local/chat_local_source.dart';
import 'package:nasmotives/core/chat/data/source/remote/nastech_api_source.dart';
import 'package:nasmotives/core/chat/domain/entity/chat_failure.dart';
import 'package:nasmotives/core/chat/domain/entity/chat_message.dart';
import 'package:nasmotives/core/chat/domain/entity/chat_session.dart';
import 'package:nasmotives/core/chat/domain/entity/nastech_config.dart';
import 'package:nasmotives/core/chat/domain/repo/chat_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: ChatRepo)
class ChatRepoImpl implements ChatRepo {
  final NasTechApiSource _apiSource;
  final ChatLocalSource _localSource;

  ChatRepoImpl(SharedPreferences prefs)
      : _apiSource = NasTechApiSource(),
        _localSource = ChatLocalSource(prefs);

  @override
  NasTechConfig? get savedConfig => _localSource.getConfig();

  @override
  Future<void> saveConfig(NasTechConfig config) =>
      _localSource.saveConfig(config);

  @override
  Future<Either<ChatFailure, Stream<String>>> sendMessage({
    required List<ChatMessage> history,
    required String userMessage,
    required NasTechConfig config,
  }) async {
    try {
      final stream = _apiSource.streamChat(
        history: history,
        userMessage: userMessage,
        config: config,
      );
      return Right(stream);
    } on Exception catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('connection') || msg.contains('socket')) {
        return const Left(ChatFailure.connectionError);
      }
      if (msg.contains('401') || msg.contains('auth')) {
        return const Left(ChatFailure.authError);
      }
      return const Left(ChatFailure.serverError);
    }
  }

  @override
  Future<Either<ChatFailure, List<ChatSession>>> getSessions() async {
    try {
      return Right(_localSource.getSessions());
    } catch (_) {
      return const Left(ChatFailure.unexpected);
    }
  }

  @override
  Future<Either<ChatFailure, ChatSession>> createSession(
      {String? title}) async {
    try {
      final session = ChatSession.create(title: title);
      await _localSource.saveSession(session);
      return Right(session);
    } catch (_) {
      return const Left(ChatFailure.unexpected);
    }
  }

  @override
  Future<Either<ChatFailure, Unit>> deleteSession(String sessionId) async {
    try {
      await _localSource.deleteSession(sessionId);
      return const Right(unit);
    } catch (_) {
      return const Left(ChatFailure.unexpected);
    }
  }

  @override
  Future<Either<ChatFailure, Unit>> saveSession(ChatSession session) async {
    try {
      await _localSource.saveSession(session);
      return const Right(unit);
    } catch (_) {
      return const Left(ChatFailure.unexpected);
    }
  }

  @override
  Future<Either<ChatFailure, bool>> testConnection(
      NasTechConfig config) async {
    try {
      final ok = await _apiSource.testConnection(config);
      return Right(ok);
    } catch (_) {
      return const Left(ChatFailure.connectionError);
    }
  }
}
