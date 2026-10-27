/// Domain model for AI chat message.
class AiMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const AiMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      id: json['id']?.toString() ?? '',
      text: json['content'] ?? json['text'] ?? '',
      isUser: json['role'] == 'user',
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
