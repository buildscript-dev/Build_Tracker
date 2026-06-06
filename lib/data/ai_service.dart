import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models/ai_config.dart';

/// One interface, four backends. Normalises Ollama / OpenRouter / OpenAI /
/// Claude into a single chat call so the rest of the app doesn't care which
/// engine is answering.
class AiService {
  /// Sends [history] (already including the latest user turn) plus an optional
  /// [system] prompt and returns the assistant text.
  static Future<String> chat({
    required AiConfig config,
    required List<ChatMessage> history,
    String? system,
  }) async {
    switch (config.provider) {
      case 'claude':
        return _claude(config, history, system);
      case 'ollama':
      case 'openrouter':
      case 'openai':
      default:
        return _openAiCompatible(config, history, system);
    }
  }

  /// Ollama, OpenRouter and OpenAI all speak the OpenAI /chat/completions shape.
  static Future<String> _openAiCompatible(
      AiConfig c, List<ChatMessage> history, String? system) async {
    final isOllama = c.provider == 'ollama';
    final url = Uri.parse('${_trim(c.baseUrl)}/chat/completions');
    final messages = <Map<String, String>>[
      if (system != null) {'role': 'system', 'content': system},
      ...history.map((m) => {'role': m.role, 'content': m.content}),
    ];
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (c.apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${c.apiKey}';
    }
    if (c.provider == 'openrouter') {
      headers['HTTP-Referer'] = 'https://buildtracker.app';
      headers['X-Title'] = 'Build Tracker';
    }
    // Ollama also exposes an OpenAI-compatible endpoint at /v1.
    final endpoint = isOllama
        ? Uri.parse('${_trim(c.baseUrl)}/v1/chat/completions')
        : url;

    final res = await http.post(
      endpoint,
      headers: headers,
      body: jsonEncode({'model': c.model, 'messages': messages}),
    );
    if (res.statusCode >= 400) {
      throw 'HTTP ${res.statusCode}: ${res.body}';
    }
    final data = jsonDecode(res.body);
    return (data['choices'][0]['message']['content'] as String).trim();
  }

  static Future<String> _claude(
      AiConfig c, List<ChatMessage> history, String? system) async {
    final url = Uri.parse('${_trim(c.baseUrl)}/messages');
    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': c.apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': c.model,
        'max_tokens': 1024,
        if (system != null) 'system': system,
        'messages': history
            .map((m) => {'role': m.role, 'content': m.content})
            .toList(),
      }),
    );
    if (res.statusCode >= 400) {
      throw 'HTTP ${res.statusCode}: ${res.body}';
    }
    final data = jsonDecode(res.body);
    return (data['content'][0]['text'] as String).trim();
  }

  static String _trim(String u) =>
      u.endsWith('/') ? u.substring(0, u.length - 1) : u;
}
