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

    // Refresh to show user message
    final updatedHistory = await _repository.getMessagesForPalace(currentId);
    state = state.copyWith(
        palaceId: currentId, messages: updatedHistory, isProcessing: true);

    try {
      final graphData = await _geminiService.extractGraphData(text);
      if (graphData != null) {
        await _repository.saveGraphData(currentId, graphData);
        final sysMsg =
            'System: Stored ${(graphData['nodes'] as List?)?.length ?? 0} nodes locally.';
        await _repository.saveMessage(currentId, sysMsg, false);
      } else {
        await _repository.saveMessage(
            currentId, 'System Error: Extraction failed.', false);
      }
    } catch (e) {
      await _repository.saveMessage(currentId, 'Error: $e', false);
    }

    final finalHistory = await _repository.getMessagesForPalace(currentId);
    state = state.copyWith(messages: finalHistory, isProcessing: false);
  }
}

final palaceControllerProvider =
    StateNotifierProvider<PalaceController, PalaceState>((ref) {
  return PalaceController(
      ref.read(geminiServiceProvider), ref.read(palaceRepositoryProvider));
});
