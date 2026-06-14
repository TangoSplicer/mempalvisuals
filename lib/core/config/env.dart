class Env {
  // Pulls the key from the build environment, defaults to empty string if missing
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
}
