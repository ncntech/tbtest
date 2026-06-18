class NasTechConfig {
  final String baseUrl;
  final String? apiKey;
  final String model;
  final bool streamingEnabled;
  final int maxTokens;
  final double temperature;

  const NasTechConfig({
    required this.baseUrl,
    this.apiKey,
    this.model = 'gpt-4o-mini',
    this.streamingEnabled = true,
    this.maxTokens = 2048,
    this.temperature = 0.7,
  });

  static const defaultLocalUrl = 'http://localhost:8000/v1';
  static const nastechPortalUrl = 'https://portal.nastech.com/v1';
  static const openRouterUrl = 'https://openrouter.ai/api/v1';

  factory NasTechConfig.local({String? apiKey}) => NasTechConfig(
        baseUrl: defaultLocalUrl,
        apiKey: apiKey,
      );

  factory NasTechConfig.portal({required String apiKey}) => NasTechConfig(
        baseUrl: nastechPortalUrl,
        apiKey: apiKey,
      );

  NasTechConfig copyWith({
    String? baseUrl,
    String? apiKey,
    String? model,
    bool? streamingEnabled,
    int? maxTokens,
    double? temperature,
  }) {
    return NasTechConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      streamingEnabled: streamingEnabled ?? this.streamingEnabled,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
    );
  }
}
