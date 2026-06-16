import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  final Dio _dio;
  final String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent';

  GeminiService() : _dio = Dio();

  Future<Map<String, dynamic>?> extractGraphData(String userInput) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key') ?? '';

    if (apiKey.isEmpty) {
      throw Exception('API Key is missing. Please configure it in Settings.');
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
        '$_endpoint?key=$apiKey',
        data: payload,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        String textResponse =
            response.data['candidates'][0]['content']['parts'][0]['text'];

        // CRITICAL FIX: Strip markdown code blocks if the LLM disobeys formatting instructions
        textResponse = textResponse
            .replaceAll(RegExp(r'```json\n?'), '')
            .replaceAll(RegExp(r'```\n?'), '')
            .trim();

        return jsonDecode(textResponse);
      } else {
        throw Exception('API returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Expose the actual network error from Google
      throw Exception('Network Error: ${e.response?.data ?? e.message}');
    } catch (e) {
      // Expose JSON parsing errors
      throw Exception('Parsing Error: $e');
    }
  }
}
