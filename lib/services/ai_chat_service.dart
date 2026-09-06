import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';
import '../models/scan_result.dart';

/// Talks to the `ai-chat` Supabase Edge Function, which holds the actual
/// LLM API key server-side (see supabase/functions/ai-chat). The app never
/// calls an AI provider directly -- that would mean shipping a secret key
/// inside the APK, which is not safe.
///
/// Like [SupabaseService], every call here fails loudly to the *caller*
/// (the chat provider decides how to show that), but never crashes the
/// app -- the on-device scan flow works with zero backend regardless.
class AIChatService {
  AIChatService({required this.enabled});

  final bool enabled;

  /// Sends one user message plus recent turns for context and returns the
  /// assistant's reply text.
  ///
  /// [languageCode] / [languageName] tell the model which language to
  /// reply in. [location] and [preferredCrops] are optional farmer context.
  /// [scanContext], when present, is the diagnosis the farmer is asking
  /// about -- this is what lets "ask AI" from the results screen give a
  /// genuinely specific answer instead of a generic one.
  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> history,
    required String languageCode,
    required String languageName,
    String? location,
    List<String> preferredCrops = const [],
    ScanResult? scanContext,
  }) async {
    if (!enabled) {
      throw StateError('ai-chat-not-configured');
    }

    final payload = <String, dynamic>{
      'message': message,
      'history': history
          // The edge function only needs recent turns to keep the prompt
          // small and cheap -- the full history stays on-device in the
          // chat screen's own state.
          .skip(history.length > 12 ? history.length - 12 : 0)
          .map((m) => m.toApiTurn())
          .toList(),
      'language': {'code': languageCode, 'name': languageName},
      if (location != null && location.isNotEmpty) 'location': location,
      if (preferredCrops.isNotEmpty) 'preferredCrops': preferredCrops,
      if (scanContext != null)
        'scanContext': {
          'cropName': scanContext.diagnosis.cropName,
          'diseaseName': scanContext.diagnosis.diseaseName,
          'isHealthy': scanContext.diagnosis.isHealthy,
          'description': scanContext.diagnosis.description,
          'confidencePercent': (scanContext.confidence * 100).round(),
          'severity': scanContext.severity.name,
        },
    };

    final response = await Supabase.instance.client.functions.invoke(
      'ai-chat',
      body: payload,
    );

    if (response.status != 200) {
      throw StateError('ai-chat-error-${response.status}');
    }

    final data = response.data;
    final reply = data is Map ? data['reply'] as String? : null;
    if (reply == null || reply.trim().isEmpty) {
      throw StateError('ai-chat-empty-reply');
    }
    return reply.trim();
  }
}
