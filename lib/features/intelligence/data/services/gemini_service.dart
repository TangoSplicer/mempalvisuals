import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  final Dio _dio;
  final String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  GeminiService() : _dio = Dio();

  Future<String?> generateRoomTitle(String firstMessage) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key') ?? '';
    if (apiKey.isEmpty) return null;

    final payload = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Summarize this into a concise 2-4 word title. Respond ONLY with the title. Message: $firstMessage"
            }
          ]
        }
      ],
      "generationConfig": {"temperature": 0.3}
    };

    try {
      final response = await _dio.post('$_endpoint?key=$apiKey',
          data: payload,
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        return response.data['candidates'][0]['content']['parts'][0]['text']
            .toString()
            .trim();
      }
    } catch (_) {}
    return null;
  }

  Future<String?> generateConversationalReply(String userInput,
      String localContext, List<Map<String, dynamic>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key') ?? '';
    if (apiKey.isEmpty) throw Exception('API Key missing.');

    final systemInstruction = '''
You are a conversational AI proxy for a sovereign engineering knowledge base. 
Use the provided LOCAL MEMORY CONTEXT to ground your answers in the user's documented reality. 
If the context does not contain the answer, you may rely on your general knowledge. Be concise, direct, and conversational.

LOCAL MEMORY CONTEXT:
$localContext
''';

    List<Map<String, dynamic>> contents = [];
    final recentHistory =
        history.length > 10 ? history.sublist(history.length - 10) : history;
    for (var msg in recentHistory) {
      if (msg['text'].toString().startsWith('System:')) continue;
      contents.add({
        "role": msg['isUser'] == true ? "user" : "model",
        "parts": [
          {"text": msg['text']}
        ]
      });
    }

    contents.add({
      "role": "user",
      "parts": [
        {"text": userInput}
      ]
    });

    final payload = {
      "systemInstruction": {
        "parts": [
          {"text": systemInstruction}
        ]
      },
      "contents": contents,
      "generationConfig": {"temperature": 0.7}
    };

    try {
      final response = await _dio.post(
        '$_endpoint?key=$apiKey',
        data: payload,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return response.data['candidates'][0]['content']['parts'][0]['text'];
      }
    } catch (e) {
      throw Exception('RAG Generation Error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> extractGraphData(String userInput) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key') ?? '';
    if (apiKey.isEmpty) return null;

    final systemPrompt = '''
You are a Universal Knowledge Graph Extraction Engine.
Analyze the user's input and extract an ontology of discrete entities and their relational links. 
RULES:
1. Nodes represent distinct entities (Technical or General).
2. Edges represent strict relationships (DEPENDS_ON, CAUSES, OWNS, WORKS_FOR).
3. Pack descriptive context directly into labels.
4. CRITICAL: Create DEEP HIERARCHIES and chains, not flat star-schemas.

EXPECTED OUTPUT FORMAT:
{
  "nodes": [{"id": "unique_id", "label": "Label Text"}],
  "edges": [{"source": "id_1", "target": "id_2", "label": "RELATIONSHIP"}]
}
Return ONLY a valid JSON object.
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
          String textResponse =
              response.data['candidates'][0]['content']['parts'][0]['text'];
          textResponse = textResponse
              .replaceAll(RegExp(r'```json\n?'), '')
              .replaceAll(RegExp(r'```\n?'), '')
              .trim();
          return jsonDecode(textResponse);
        } else if (response.statusCode == 503) {
          if (attempt == maxRetries) return null;
          await Future.delayed(Duration(milliseconds: retryDelay * attempt));
          continue;
        }
      } catch (e) {
        if (attempt == maxRetries) return null;
      }
    }
    return null;
  }
}
