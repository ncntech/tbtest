import 'dart:convert';
import 'package:nasmotives/core/chat/domain/entity/chat_message.dart';
import 'package:nasmotives/core/chat/domain/entity/chat_session.dart';
import 'package:nasmotives/core/chat/domain/entity/nastech_config.dart';
import 'package:nasmotives/core/misc/domain/entity/unique_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatLocalSource {
  static const _sessionsKey = 'nasmotives_chat_sessions';
  static const _configKey = 'nasmotives_nastech_config';

  final SharedPreferences _prefs;

  ChatLocalSource(this._prefs);

  List<ChatSession> getSessions() {
    final raw = _prefs.getString(_sessionsKey);
    if (raw == null) return [];
    try {
      final List decoded = json.decode(raw);
      return decoded.map((e) => _sessionFromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSession(ChatSession session) async {
    final sessions = getSessions();
    final idx = sessions.indexWhere((s) => s.id.value == session.id.value);
    if (idx >= 0) {
      sessions[idx] = session;
    } else {
      sessions.insert(0, session);
    }
    await _prefs.setString(
        _sessionsKey, json.encode(sessions.map(_sessionToMap).toList()));
  }

  Future<void> deleteSession(String sessionId) async {
    final sessions = getSessions()
        .where((s) => s.id.value.toString() != sessionId)
        .toList();
    await _prefs.setString(
        _sessionsKey, json.encode(sessions.map(_sessionToMap).toList()));
  }

  NasTechConfig? getConfig() {
    final raw = _prefs.getString(_configKey);
    if (raw == null) return null;
    try {
      final map = json.decode(raw);
      return NasTechConfig(
        baseUrl: map['baseUrl'] ?? NasTechConfig.defaultLocalUrl,
        apiKey: map['apiKey'],
        model: map['model'] ?? 'gpt-4o-mini',
        streamingEnabled: map['streamingEnabled'] ?? true,
        maxTokens: map['maxTokens'] ?? 2048,
        temperature: (map['temperature'] ?? 0.7).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveConfig(NasTechConfig config) async {
    await _prefs.setString(
        _configKey,
        json.encode({
          'baseUrl': config.baseUrl,
          'apiKey': config.apiKey,
          'model': config.model,
          'streamingEnabled': config.streamingEnabled,
          'maxTokens': config.maxTokens,
          'temperature': config.temperature,
        }));
  }

  Map<String, dynamic> _sessionToMap(ChatSession s) => {
        'id': s.id.value,
        'title': s.title,
        'createdAt': s.createdAt.toIso8601String(),
        'updatedAt': s.updatedAt.toIso8601String(),
        'messages': s.messages.map(_msgToMap).toList(),
      };

  Map<String, dynamic> _msgToMap(ChatMessage m) => {
        'id': m.id.value,
        'role': m.role.name,
        'content': m.content,
        'timestamp': m.timestamp.toIso8601String(),
        'status': 'sent',
      };

  ChatSession _sessionFromMap(Map e) => ChatSession(
        id: UniqueId.fromValue(e['id']),
        title: e['title'] ?? 'Chat',
        createdAt: DateTime.tryParse(e['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(e['updatedAt'] ?? '') ?? DateTime.now(),
        messages: (e['messages'] as List? ?? [])
            .map((m) => _msgFromMap(m))
            .toList(),
      );

  ChatMessage _msgFromMap(Map m) => ChatMessage(
        id: UniqueId.fromValue(m['id']),
        role: ChatRole.values.firstWhere(
          (r) => r.name == m['role'],
          orElse: () => ChatRole.user,
        ),
        content: m['content'] ?? '',
        timestamp: DateTime.tryParse(m['timestamp'] ?? '') ?? DateTime.now(),
        status: ChatMessageStatus.sent,
      );
}
