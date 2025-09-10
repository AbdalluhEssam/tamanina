/// Configuration for API keys and endpoints
class ApiConfig {
  // ChatGPT/OpenAI Configuration
  static const String openAIApiKey =
      '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';
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String chatCompletionsEndpoint = '/chat/completions';

  // Default model configurations - using more cost-effective model
  static const String defaultModel = 'gpt-3.5-turbo-16k';
  static const int maxTokens = 1500;
  static const double temperature = 0.8;
  static const int timeoutSeconds = 45;

  // Request limits
  static const int maxConversationHistory = 10; // Reduced to save tokens
  static const Duration streamingDelay = Duration(milliseconds: 40);

  // Retry configuration
  static const int maxRetries = 2;
  static const Duration retryDelay = Duration(seconds: 2);
}
