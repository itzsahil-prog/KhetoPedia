import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../domain/ai_message.dart';

/// Repository for AI chat operations.
class AiRepository {
  final Dio _dio;

  AiRepository(this._dio);

  /// Send a message to AI assistant and get response.
  Future<({String? error, AiMessage? value})> sendMessage({
    required String message,
    int? conversationId,
    int? fieldId,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/ai/chat',
        data: {
          'message': message,
          if (conversationId != null) 'conversation_id': conversationId,
          if (fieldId != null) 'field_id': fieldId,
        },
      );

      final data = response.data;
      
      // Backend returns: { "message": "...", "conversation_id": 123 }
      final aiMessage = AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: data['message'] ?? data['response'] ?? 'No response',
        isUser: false,
        timestamp: DateTime.now(),
      );

      return (error: null, value: aiMessage);
    } on DioException catch (e) {
      String errorMsg = 'Failed to get AI response';
      if (e.response?.data != null && e.response!.data is Map) {
        errorMsg = e.response!.data['detail'] ?? errorMsg;
      }
      return (error: errorMsg, value: null);
    } catch (e) {
      return (error: 'Unexpected error: $e', value: null);
    }
  }

  /// Get conversation history.
  Future<({String? error, List<AiMessage>? value})> getConversations() async {
    try {
      final response = await _dio.get('/v1/ai/conversations');
      
      final conversations = (response.data as List)
          .map((json) => AiMessage.fromJson(json))
          .toList();

      return (error: null, value: conversations);
    } on DioException catch (e) {
      String errorMsg = 'Failed to load conversations';
      if (e.response?.data != null && e.response!.data is Map) {
        errorMsg = e.response!.data['detail'] ?? errorMsg;
      }
      return (error: errorMsg, value: null);
    } catch (e) {
      return (error: 'Unexpected error: $e', value: null);
    }
  }
}
