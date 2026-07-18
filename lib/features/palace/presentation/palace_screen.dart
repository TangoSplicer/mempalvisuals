import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../application/palace_controller.dart';
import '../../graph/presentation/screens/graph_screen.dart';

class PalaceScreen extends ConsumerStatefulWidget {
  final int? existingPalaceId;
  const PalaceScreen({super.key, this.existingPalaceId});

  @override
  ConsumerState<PalaceScreen> createState() => _PalaceScreenState();
}

class _PalaceScreenState extends ConsumerState<PalaceScreen> {
  final TextEditingController _thoughtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingPalaceId != null) {
      Future.microtask(() => ref
          .read(palaceControllerProvider.notifier)
          .loadExistingPalace(widget.existingPalaceId!));
    } else {
      Future.microtask(
          () => ref.read(palaceControllerProvider.notifier).clearState());
    }
  }

  void _handleSubmitting() {
    if (_thoughtController.text.isNotEmpty) {
      ref
          .read(palaceControllerProvider.notifier)
          .submitThought(_thoughtController.text);
      _thoughtController.clear();
    }
  }

  Future<void> _handleFileAttachment() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;

        // Hand off to the controller's bulk pipeline
        ref
            .read(palaceControllerProvider.notifier)
            .ingestDocument(filePath, fileName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(palaceControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.existingPalaceId != null ? 'Memory Room' : 'New Room'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        actions: [
          if (widget.existingPalaceId != null)
            IconButton(
              icon: const Icon(Icons.hub),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          GraphScreen(palaceId: widget.existingPalaceId))),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final msg = state.messages[index];
                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? Colors.teal.shade700
                          : Colors.blueGrey.shade800,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(msg.messageText,
                        style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          if (state.isProcessing) const LinearProgressIndicator(),
          if (state.isExtracting)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.teal)),
                  const SizedBox(width: 12),
                  Text('Mapping neural pathways...',
                      style: TextStyle(
                          color: Colors.grey.shade400,
                          fontStyle: FontStyle.italic,
                          fontSize: 13)),
                ],
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.teal),
                    onPressed: state.isExtracting
                        ? null
                        : _handleFileAttachment, // Disable while extracting
                  ),
                  Expanded(
                    child: TextField(
                      controller: _thoughtController,
                      decoration: const InputDecoration(
                          hintText: 'Enter thought...',
                          border: OutlineInputBorder()),
                      onSubmitted: (_) => _handleSubmitting(),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _handleSubmitting),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
