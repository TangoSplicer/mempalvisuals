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

    var history = await _repository.getMessagesForPalace(currentId);
    state = state.copyWith(
        palaceId: currentId, messages: history, isProcessing: true);

    if (history.where((m) => m.isUser).length == 1) {
      _geminiService.generateRoomTitle(text).then((title) {
        if (title != null && title.isNotEmpty)
          _repository.updateRoomTitle(currentId, title);
      });
    }

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

    List<Map<String, dynamic>> mappedHistory = history
        .map((m) => {'isUser': m.isUser, 'text': m.messageText})
        .toList();

    try {
      final aiResponse = await _geminiService.generateConversationalReply(
          text, contextBuilder.toString(), mappedHistory);
      if (aiResponse != null) {
        await _repository.saveMessage(currentId, aiResponse, false);
      } else {
        await _repository.saveMessage(currentId,
            'System Error: Failed to generate conversational response.', false);
      }
    } catch (e) {
      await _repository.saveMessage(currentId, 'Error: $e', false);
    }

    history = await _repository.getMessagesForPalace(currentId);
    state = state.copyWith(messages: history, isProcessing: false);

    // Fire non-blocking extraction with UI notification
    _runBackgroundExtraction(text, currentId);
  }

  Future<void> _runBackgroundExtraction(String text, int currentId) async {
    try {
      final graphData = await _geminiService.extractGraphData(text);
      if (graphData != null) {
        final nodeCount = (graphData['nodes'] as List?)?.length ?? 0;
        await _repository.saveGraphData(currentId, graphData);
        // Expose success to UI
        await _repository.saveMessage(
            currentId,
            'System (Background): Successfully mapped $nodeCount new nodes to the Knowledge Graph.',
            false);
      } else {
        await _repository.saveMessage(
            currentId, 'System (Background): No entities extracted.', false);
      }
    } catch (e) {
      // Expose exact errors to UI
      await _repository.saveMessage(
          currentId, 'System (Background) Error: $e', false);
    }

    // Refresh the UI state to show the background message
    final history = await _repository.getMessagesForPalace(currentId);
    state = state.copyWith(messages: history);
  }
}

final palaceControllerProvider =
    StateNotifierProvider<PalaceController, PalaceState>((ref) {
  return PalaceController(
      ref.read(geminiServiceProvider), ref.read(palaceRepositoryProvider));
});
