import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:nasmotives/core/chat/domain/entity/chat_message.dart';
import 'package:nasmotives/core/chat/domain/entity/nastech_config.dart';

class NasTechApiSource {
  Dio _buildDio(NasTechConfig config) {
    final dio = Dio(BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
      headers: {
        'Content-Type': 'application/json',
        if (config.apiKey != null && config.apiKey!.isNotEmpty)
          'Authorization': 'Bearer ${config.apiKey}',
      },
    ));
    return dio;
  }

  List<Map<String, dynamic>> _buildMessages(
      List<ChatMessage> history, String userMessage) {
    final msgs = <Map<String, dynamic>>[];
    msgs.add({
      'role': 'system',
      'content':
          'You are NasTech AI, an intelligent assistant powered by NasTech. '
              'You are helpful, precise, and thoughtful in your responses.',
    });
    for (final msg in history) {
      msgs.add({
        'role': msg.role == ChatRole.user ? 'user' : 'assistant',
        'content': msg.content,
      });
    }
    msgs.add({'role': 'user', 'content': userMessage});
    return msgs;
  }

  Stream<String> streamChat({
    required List<ChatMessage> history,
    required String userMessage,
    required NasTechConfig config,
  }) async* {
    final dio = _buildDio(config);
    final body = {
      'model': config.model,
      'messages': _buildMessages(history, userMessage),
      'stream': true,
      'max_tokens': config.maxTokens,
      'temperature': config.temperature,
    };

    final response = await dio.post<ResponseBody>(
      '/chat/completions',
      data: json.encode(body),
      options: Options(responseType: ResponseType.stream),
    );

    await for (final chunk in response.data!.stream) {
      final lines = utf8.decode(chunk).split('\n');
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6).trim();
          if (data == '[DONE]') return;
          try {
            final decoded = json.decode(data);
            final delta =
                decoded['choices']?[0]?['delta']?['content'] as String?;
            if (delta != null && delta.isNotEmpty) {
              yield delta;
            }
          } catch (_) {}
        }
      }
    }
  }

  Future<bool> testConnection(NasTechConfig config) async {
    try {
      final dio = _buildDio(config);
      final response = await dio.get('/models');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
