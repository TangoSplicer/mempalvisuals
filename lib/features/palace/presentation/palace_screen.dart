import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/palace_controller.dart';

class PalaceScreen extends ConsumerStatefulWidget {
  const PalaceScreen({super.key});

  @override
  ConsumerState<PalaceScreen> createState() => _PalaceScreenState();
}

class _PalaceScreenState extends ConsumerState<PalaceScreen> {
  final TextEditingController _thoughtController = TextEditingController();

  void _handleSubmitting() {
    final text = _thoughtController.text.trim();
    if (text.isNotEmpty) {
      ref.read(palaceControllerProvider.notifier).submitThought(text);
      _thoughtController.clear();
    }
  }

  @override
  void dispose() {
    _thoughtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(palaceControllerProvider);

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
            child: state.messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Room is empty.\nType your thought below to begin relational extraction.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      return Align(
                        alignment: msg.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: msg.isUser
                                ? Colors.teal.shade700
                                : Colors.blueGrey.shade800,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(
                            msg.text,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (state.isProcessing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(color: Colors.teal),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _thoughtController,
                      enabled: !state.isProcessing,
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
                    backgroundColor:
                        state.isProcessing ? Colors.grey : Colors.teal,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: state.isProcessing ? null : _handleSubmitting,
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
}
