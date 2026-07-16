import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../intelligence/data/services/gemini_service.dart';
import '../../intelligence/application/gemini_provider.dart';
import '../../database/data/palace_repository.dart';
import '../../database/data/database.dart' show ChatMessage;

class PalaceState {
  final int? palaceId;
  final List<ChatMessage> messages;
  final bool isProcessing;
  PalaceState(
      {this.palaceId, this.messages = const [], this.isProcessing = false});
  PalaceState copyWith(
      {int? palaceId, List<ChatMessage>? messages, bool? isProcessing}) {
    return PalaceState(
      palaceId: palaceId ?? this.palaceId,
      messages: messages ?? this.messages,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class PalaceController extends StateNotifier<PalaceState> {
  final GeminiService _geminiService;
  final PalaceRepository _repository;

  PalaceController(this._geminiService, this._repository)
      : super(PalaceState());

  void clearState() {
    state = PalaceState();
  }

  Future<void> loadExistingPalace(int palaceId) async {
    final history = await _repository.getMessagesForPalace(palaceId);
    state = state.copyWith(palaceId: palaceId, messages: history);
  }

  Future<void> submitThought(String text) async {
    if (text.isEmpty) return;

    int currentId = state.palaceId ??
        await _repository.createRoom(
            'Session ${DateTime.now().toLocal().toString().split('.')[0]}');
    await _repository.saveMessage(currentId, text, true);

    // Pre-load current chat history
    var history = await _repository.getMessagesForPalace(currentId);
    state = state.copyWith(
        palaceId: currentId, messages: history, isProcessing: true);

    // Build the RAG Context from the SQLite Knowledge Graph
    final nodes = await _repository.getNodesForPalace(currentId);
    final edges = await _repository.getEdgesForPalace(currentId);
    final contextBuilder = StringBuffer();

    if (nodes.isNotEmpty) {
      contextBuilder.writeln("--- EXISTING GRAPH NODES ---");
      for (var n in nodes) {
        contextBuilder.writeln("ID: ${n.id} | Label: ${n.label}");
      }
    }
    if (edges.isNotEmpty) {
      contextBuilder.writeln("--- CAUSAL RELATIONSHIPS ---");
      for (var e in edges) {
        contextBuilder
            .writeln("[${e.sourceId}] --(${e.label})--> [${e.targetId}]");
      }
    }

    // Format history for the AI payload
    List<Map<String, dynamic>> mappedHistory = history
        .map((m) => {'isUser': m.isUser, 'text': m.messageText})
        .toList();

    // TRACK 1: Fire Conversational Generation (Foreground)
    try {
      final aiResponse = await _geminiService.generateConversationalReply(
          text, contextBuilder.toString(), mappedHistory);
      if (aiResponse != null) {
        await _repository.saveMessage(currentId, aiResponse, false);
      } else {
        await _repository.saveMessage(
            currentId, 'System Error: Failed to generate response.', false);
      }
    } catch (e) {
      await _repository.saveMessage(currentId, 'Error: $e', false);
    }

    // Refresh UI with the AI's chat reply immediately
    history = await _repository.getMessagesForPalace(currentId);
    state = state.copyWith(messages: history, isProcessing: false);

    // TRACK 2: Fire Deep Graph Extraction (Background - Non-blocking)
    _runBackgroundExtraction(text, currentId);

    // TRACK 3: Auto-name the room if this is the first real message
    if (history.where((m) => m.isUser).length == 1) {
      _geminiService.generateRoomTitle(text).then((title) {
        if (title != null && title.isNotEmpty) {
          _repository.updateRoomTitle(currentId, title);
        }
      });
    }
  }

  Future<void> _runBackgroundExtraction(String text, int currentId) async {
    try {
      final graphData = await _geminiService.extractGraphData(text);
      if (graphData != null) {
        await _repository.saveGraphData(currentId, graphData);
      }
    } catch (e) {
      // Fail silently in the background to prevent UI disruption
      print('Background Extraction Error: $e');
    }
  }
}

final palaceControllerProvider =
    StateNotifierProvider<PalaceController, PalaceState>((ref) {
  return PalaceController(
      ref.read(geminiServiceProvider), ref.read(palaceRepositoryProvider));
});
