import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/scan_result.dart';
import '../services/ai_chat_service.dart';

enum ChatStatus { idle, sending, error }

/// Drives the AI-assistant conversation. Mirrors [ScanProvider]'s shape
/// (a status enum plus a single provider owning the flow) so the pattern
/// stays consistent across the app.
///
/// Conversation state is kept in memory only -- reopening the assistant
/// starts fresh, the same way a farmer would expect a "call an expert"
/// button to work rather than a saved thread they need to manage.
class ChatProvider extends ChangeNotifier {
  final AIChatService _service;

  ChatProvider(this._service);

  final List<ChatMessage> messages = [];
  ChatStatus status = ChatStatus.idle;
  String? errorMessage;

  bool get isConfigured => _service.enabled;

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Seeds the conversation with a contextual opening message when the
  /// assistant is opened right after a scan, so the farmer lands on
  /// something specific rather than a blank chat.
  void seedWithScanResult(ScanResult result, {required String Function(String) tr}) {
    if (messages.isNotEmpty) return;
    final diagnosis = result.diagnosis;
    final opening = diagnosis.isHealthy
        ? '${tr('chatSeedHealthyIntro')} ${diagnosis.cropName}.'
        : '${tr('chatSeedIssueIntro')} ${diagnosis.cropName} — ${diagnosis.diseaseName}.';
    messages.add(
      ChatMessage(
        id: _newId(),
        role: ChatRole.assistant,
        content: '$opening ${tr('chatSeedPrompt')}',
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void seedWithWelcome(String text) {
    if (messages.isNotEmpty) return;
    messages.add(
      ChatMessage(id: _newId(), role: ChatRole.assistant, content: text, timestamp: DateTime.now()),
    );
    notifyListeners();
  }

  Future<void> sendMessage(
    String text, {
    required String languageCode,
    required String languageName,
    String? location,
    List<String> preferredCrops = const [],
    ScanResult? scanContext,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || status == ChatStatus.sending) return;

    messages.add(ChatMessage(id: _newId(), role: ChatRole.user, content: trimmed, timestamp: DateTime.now()));
    status = ChatStatus.sending;
    errorMessage = null;
    notifyListeners();

    try {
      final reply = await _service.sendMessage(
        message: trimmed,
        history: messages,
        languageCode: languageCode,
        languageName: languageName,
        location: location,
        preferredCrops: preferredCrops,
        scanContext: scanContext,
      );
      messages.add(ChatMessage(id: _newId(), role: ChatRole.assistant, content: reply, timestamp: DateTime.now()));
      status = ChatStatus.idle;
    } catch (e) {
      status = ChatStatus.error;
      errorMessage = e.toString().contains('ai-chat-not-configured')
          ? 'not_configured'
          : 'generic_error';
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    messages.clear();
    status = ChatStatus.idle;
    errorMessage = null;
    notifyListeners();
  }
}
