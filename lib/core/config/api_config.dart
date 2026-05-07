/// Configuration for API keys and endpoints
class ApiConfig {
  // Groq API Configuration - Fast and efficient AI models
  static const String openAIApiKey =
      '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';

  static const String openAIBaseUrl = 'https://api.groq.com/openai/v1';
  static const String chatCompletionsEndpoint = '/chat/completions';

  // Default model configurations - using Groq's fast Llama model
  static const String defaultModel =
      'meta-llama/llama-4-scout-17b-16e-instruct';
  static const int maxTokens = 500;
  static const double temperature = 0.3;
  static const int timeoutSeconds = 45;

  // Request limits
  static const int maxConversationHistory = 10; // Reduced to save tokens
  static const Duration streamingDelay =
      Duration(milliseconds: 30); // Faster for Groq

  // Retry configuration
  static const int maxRetries = 2;
  static const Duration retryDelay = Duration(seconds: 2);
}
