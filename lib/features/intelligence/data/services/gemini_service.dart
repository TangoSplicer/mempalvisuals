import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  final Dio _dio;
  final String _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  GeminiService() : _dio = Dio();

  Future<Map<String, dynamic>?> extractGraphData(String userInput) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key') ?? '';

    if (apiKey.isEmpty) {
      throw Exception('API Key is missing. Please configure it in Settings.');
    }

    final systemPrompt = '''
You are a Universal Knowledge Graph Extraction Engine.
Analyze the user's input and extract an ontology of discrete entities and their relational links. 

RULES:
1. Nodes represent distinct entities. These can be Technical (Software, Hardware, Errors, Architectures) OR General (People, Assets, Organizations, Concepts, Locations).
2. Edges represent strict relationships (e.g., OWNS, SIBLING_OF, WORKS_FOR, DEPENDS_ON, CAUSES, LIKES).
3. Pack descriptive context directly into the node labels.

EXPECTED OUTPUT FORMAT:
{
  "nodes": [
    {"id": "jason_user", "label": "Jason (User, Age 35)"},
    {"id": "peugeot_5008", "label": "Blue Peugeot 5008"},
    {"id": "hmrc_gov", "label": "HMRC (Employer)"}
  ],
  "edges": [
    {"source": "jason_user", "target": "peugeot_5008", "label": "OWNS"},
    {"source": "jason_user", "target": "hmrc_gov", "label": "WORKS_FOR"}
  ]
}

Return ONLY a valid JSON object matching the above schema. Do not include markdown formatting, backticks, or conversational text.
''';

    final payload = {
      "contents": [{"parts": [{"text": systemPrompt}, {"text": "User Input: $userInput"}]}],
      "generationConfig": {"temperature": 0.1, "responseMimeType": "application/json"}
    };

    int maxRetries = 3;
    int retryDelay = 2000; 

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await _dio.post(
          '$_endpoint?key=$apiKey',
          data: payload,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            validateStatus: (status) => status != null && status < 600, 
          ),
        );

        if (response.statusCode == 200) {
          String textResponse = response.data['candidates'][0]['content']['parts'][0]['text'];
          textResponse = textResponse.replaceAll(RegExp(r'```json\n?'), '').replaceAll(RegExp(r'```\n?'), '').trim();
          return jsonDecode(textResponse);
        } else if (response.statusCode == 503) {
          if (attempt == maxRetries) {
            throw Exception('API is overloaded (503). Retried $maxRetries times. Please try again later.');
          }
          await Future.delayed(Duration(milliseconds: retryDelay * attempt));
          continue;
        } else {
          throw Exception('API returned ${response.statusCode}: ${response.data}');
        }
      } on DioException catch (e) {
        throw Exception('Network Error: ${e.response?.data ?? e.message}');
      } catch (e) {
        if (attempt == maxRetries) {
          throw Exception('Error: $e');
        }
      }
    }
    return null;
  }
}
