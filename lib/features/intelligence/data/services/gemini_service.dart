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
You are a Deep Graph Extraction Engine for a sovereign engineering knowledge base.
Analyze the user's technical log and extract an advanced ontology mapping causal relationships, architectural decisions, dependencies, and state changes.

RULES:
1. Nodes must represent discrete entities, concepts, systems, errors, or files.
2. Edges must represent strict causal, hierarchical, or temporal relationships (Use exact uppercase labels like DEPENDS_ON, CAUSES, RESOLVES, IMPLEMENTS, DEPRECATES, CONFLICTS_WITH).
3. Pack critical technical context directly into the labels to preserve detail.

EXAMPLE INTERACTION: 
"I had to rewrite the WhisperNet gossip protocol in Rust because the WASM cross-compilation in Termux was throwing a memory fault."

EXPECTED OUTPUT FORMAT:
{
  "nodes": [
    {"id": "whispernet_gossip", "label": "WhisperNet Gossip Protocol (Rust)"},
    {"id": "wasm_termux_build", "label": "WASM Cross-compilation in Termux"},
    {"id": "mem_fault_0x1", "label": "Memory Fault Error"}
  ],
  "edges": [
    {"source": "wasm_termux_build", "target": "mem_fault_0x1", "label": "CAUSES"},
    {"source": "whispernet_gossip", "target": "mem_fault_0x1", "label": "RESOLVES"}
  ]
}

Return ONLY a valid JSON object matching the above schema. Do not include markdown formatting, backticks, or conversational text.
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
        textResponse = textResponse
            .replaceAll(RegExp(r'```json\n?'), '')
            .replaceAll(RegExp(r'```\n?'), '')
            .trim();
        return jsonDecode(textResponse);
      } else {
        throw Exception('API returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network Error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Parsing Error: $e');
    }
  }
}
