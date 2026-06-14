import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../intelligence/application/gemini_provider.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final TextEditingController _thoughtController = TextEditingController();
  bool _isProcessing = false;
  String _structuredOutput = '';

  Future<void> _extractKnowledge() async {
    final text = _thoughtController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _structuredOutput = '';
    });

    // Call the Gemini API via Riverpod
    final service = ref.read(geminiServiceProvider);
    final rawJsonMap = await service.extractGraphData(text);

    setState(() {
      _isProcessing = false;
      if (rawJsonMap != null) {
        // Pretty-print the JSON so you can inspect the nodes and edges
        _structuredOutput =
            const JsonEncoder.withIndent('  ').convert(rawJsonMap);
      } else {
        _structuredOutput =
            'Error: Failed to extract data. Check your API key and connection.';
      }
    });
  }

  @override
  void dispose() {
    _thoughtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Thought'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _thoughtController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g., I acquired a 2023 Peugeot 5008 vehicle...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _extractKnowledge,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
              label:
                  Text(_isProcessing ? 'Extracting...' : 'Structure Thought'),
            ),
            const SizedBox(height: 24),
            const Text('LLM Output:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _structuredOutput.isEmpty
                        ? 'Waiting for input...'
                        : _structuredOutput,
                    style: const TextStyle(
                        color: Colors.greenAccent, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
