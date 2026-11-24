class ApiConfig {
  static const guideEndpoint = String.fromEnvironment('TAMANINA_GUIDE_URL');
  static const defaultModel = 'default';

  static Uri? get guideUri {
    final uri = Uri.tryParse(guideEndpoint);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
        ? uri
        : null;
  }
}
