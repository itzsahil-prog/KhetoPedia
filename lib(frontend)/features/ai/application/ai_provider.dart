import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_providers.dart';
import '../data/ai_repository.dart';
import '../domain/ai_message.dart';

/// Provider for AI repository.
final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.watch(dioProvider));
});

/// State for AI chat.
class AiChatState {
  final List<AiMessage> messages;
  final bool isLoading;
  final String? error;
  final int? conversationId;

  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.conversationId,
  });

  AiChatState copyWith({
    List<AiMessage>? messages,
    bool? isLoading,
    String? error,
    int? conversationId,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

/// Notifier for AI chat operations.
class AiChatNotifier extends Notifier<AiChatState> {
  @override
  AiChatState build() {
    return const AiChatState();
  }

  /// Send a message to AI assistant.
  Future<void> sendMessage(String text, {int? fieldId}) async {
    if (text.trim().isEmpty) return;

    // Add user message immediately
    final userMessage = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    // Call backend
    final repository = ref.read(aiRepositoryProvider);
    final result = await repository.sendMessage(
      message: text,
      conversationId: state.conversationId,
      fieldId: fieldId,
    );

    if (result.error != null) {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
    } else if (result.value != null) {
      state = state.copyWith(
        messages: [...state.messages, result.value!],
        isLoading: false,
        error: null,
      );
    }
  }

  /// Clear chat history (start new conversation).
  void clearChat() {
    state = const AiChatState();
  }
}

/// Provider for AI chat state.
final aiChatProvider = NotifierProvider<AiChatNotifier, AiChatState>(
  AiChatNotifier.new,
);
