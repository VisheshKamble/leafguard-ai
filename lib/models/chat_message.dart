enum ChatRole { user, assistant }

/// A single turn in an AI-chat conversation. Kept intentionally simple
/// (no attachments, no rich content) since the chatbot's job is fast,
/// practical answers in the farmer's own language -- not a rich messaging
/// experience.
class ChatMessage {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toApiTurn() => {
        'role': role == ChatRole.user ? 'user' : 'assistant',
        'content': content,
      };
}
