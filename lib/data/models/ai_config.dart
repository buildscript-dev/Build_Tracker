import '../../secrets.dart';

/// Config for one AI provider. Build Tracker speaks to multiple backends so
/// Ankit can use whatever subscription/engine he has: local Ollama (free, runs
/// on the RTX 4050), OpenRouter (many models, one key), OpenAI, or Claude.
class AiConfig {
  String provider; // ollama | openrouter | openai | claude
  String baseUrl;
  String apiKey;
  String model;

  AiConfig({
    required this.provider,
    required this.baseUrl,
    this.apiKey = '',
    required this.model,
  });

  /// Curated free OpenRouter models (the `:free` tier — no credits used).
  /// Availability rotates on OpenRouter's side; the model field stays editable
  /// so any id can be pasted manually.
  static const List<String> freeOpenRouterModels = [
    'deepseek/deepseek-chat-v3-0324:free',
    'deepseek/deepseek-r1:free',
    'meta-llama/llama-3.3-70b-instruct:free',
    'google/gemini-2.0-flash-exp:free',
    'qwen/qwen-2.5-72b-instruct:free',
    'mistralai/mistral-small-3.1-24b-instruct:free',
    'nvidia/llama-3.1-nemotron-70b-instruct:free',
  ];

  static AiConfig defaultFor(String provider) {
    switch (provider) {
      case 'ollama':
        return AiConfig(
            provider: 'ollama',
            baseUrl: 'http://localhost:11434',
            model: 'llama3.1');
      case 'openrouter':
        return AiConfig(
            provider: 'openrouter',
            baseUrl: 'https://openrouter.ai/api/v1',
            apiKey: Secrets.openRouterKey,
            model: freeOpenRouterModels.first);
      case 'openai':
        return AiConfig(
            provider: 'openai',
            baseUrl: 'https://api.openai.com/v1',
            model: 'gpt-4o-mini');
      case 'claude':
      default:
        return AiConfig(
            provider: 'claude',
            baseUrl: 'https://api.anthropic.com/v1',
            model: 'claude-sonnet-4-6');
    }
  }

  Map<String, dynamic> toMap() => {
        'provider': provider,
        'baseUrl': baseUrl,
        'apiKey': apiKey,
        'model': model,
      };

  factory AiConfig.fromMap(Map map) => AiConfig(
        provider: map['provider'] as String,
        baseUrl: map['baseUrl'] as String,
        apiKey: (map['apiKey'] ?? '') as String,
        model: map['model'] as String,
      );
}

class ChatMessage {
  final String role; // user | assistant | system
  final String content;
  final int timeMillis;

  ChatMessage(this.role, this.content, [int? time])
      : timeMillis = time ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() =>
      {'role': role, 'content': content, 'timeMillis': timeMillis};

  factory ChatMessage.fromMap(Map map) => ChatMessage(
        map['role'] as String,
        map['content'] as String,
        map['timeMillis'] as int?,
      );
}
