import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../intelligence/data/services/gemini_service.dart';
import '../../intelligence/application/gemini_provider.dart';
import '../../database/data/palace_repository.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

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

  Future<void> submitThought(String text) async {
    if (text.isEmpty) return;

    // Instantly display user thought in the UI
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(text: text, isUser: true)],
      isProcessing: true,
    );

    // Ensure a Palace container exists in SQLite
    int currentId = state.palaceId ??
        await _repository
            .createRoom('Room ${DateTime.now().toIso8601String()}');
    if (state.palaceId == null) {
      state = state.copyWith(palaceId: currentId);
    }

    try {
      // Track 2 Execution: Silent background extraction
      final graphData = await _geminiService.extractGraphData(text);

      if (graphData != null) {
        await _repository.saveGraphData(currentId, graphData);

        final nodesCount = (graphData['nodes'] as List?)?.length ?? 0;
        final edgesCount = (graphData['edges'] as List?)?.length ?? 0;

        // Track 1 Execution: System feedback response
        final sysResponse = ChatMessage(
            text:
                'System: Intercepted and securely stored $nodesCount entities and $edgesCount relationships locally.',
            isUser: false);

        state = state.copyWith(
          messages: [...state.messages, sysResponse],
          isProcessing: false,
        );
      } else {
        throw Exception('LLM returned null graph structure.');
      }
    } catch (e) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(text: 'System Error: $e', isUser: false)
        ],
        isProcessing: false,
      );
    }
  }
}

final palaceControllerProvider =
    StateNotifierProvider<PalaceController, PalaceState>((ref) {
  return PalaceController(
    ref.read(geminiServiceProvider),
    ref.read(palaceRepositoryProvider),
  );
});
