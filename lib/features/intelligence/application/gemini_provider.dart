import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/gemini_service.dart';

// Provides a global, immutable instance of the GeminiService
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});
