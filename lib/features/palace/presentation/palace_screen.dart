import 'package:flutter/material.dart';

class PalaceScreen extends StatefulWidget {
  const PalaceScreen({super.key});

  @override
  State<PalaceScreen> createState() => _PalaceScreenState();
}

class _PalaceScreenState extends State<PalaceScreen> {
  final TextEditingController _thoughtController = TextEditingController();
  final List<String> _capturedThoughts = [];

  void _handleSubmitting() {
    final text = _thoughtController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _capturedThoughts.add(text);
      });
      _thoughtController.clear();
      // Temporary user confirmation until pipeline execution services are wired up
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thought logged locally: "$text"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Memory Room'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _capturedThoughts.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Room is empty.\nType your thought below to begin relational mapping.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _capturedThoughts.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ListTile(
                          leading: const Icon(Icons.psychology, color: Colors.teal),
                          title: Text(_capturedThoughts[index]),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _thoughtController,
                      decoration: InputDecoration(
                        hintText: 'Capture thought or log action...',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 14.0,
                        ),
                      ),
                      onSubmitted: (_) => _handleSubmitting(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.teal,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _handleSubmitting,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _thoughtController.dispose();
    super.dispose();
  }
}
