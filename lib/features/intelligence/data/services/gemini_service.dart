import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/config/env.dart';

class GeminiService {
  final Dio _dio;
  
  // Hardcoded to gemini-1.5-flash for maximum speed
  final String _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  GeminiService() : _dio = Dio();

  Future<Map<String, dynamic>?> extractGraphData(String userInput) async {
    if (Env.geminiApiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is not set in the environment.');
    }

    final systemPrompt = '''
You are a knowledge graph extractor. Analyze the user's text and extract core entities as nodes and their relationships as edges.
Return ONLY a valid JSON object matching exactly this schema:
{
  "nodes": [{"id": "unique_string", "label": "Entity Name"}],
  "edges": [{"source": "node_id_1", "target": "node_id_2", "label": "relationship description"}]
}
Do not include markdown formatting, backticks, or any conversational text.
''';

    final payload = {
      "contents": [
        {
          "parts": [
            {"text": systemPrompt},
            {"text": "User Input: $userInput"}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.1, 
        "responseMimeType": "application/json" 
      }
    };

    try {
      final response = await _dio.post(
        '$_endpoint?key=${Env.geminiApiKey}',
        data: payload,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final textResponse = response.data['candidates'][0]['content']['parts'][0]['text'];
        // Decode the pure JSON string into a Dart Map
        return jsonDecode(textResponse);
      } else {
        throw Exception('Failed to connect to Gemini: ${response.statusCode}');
      }
    } catch (e) {
      print('Gemini API Error: $e');
      return null;
    }
  }
}
