import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/localization/app_languages.dart';
import '../../providers/chat_provider.dart';
import '../../models/scan_result.dart';
import '../../widgets/chat_bubble.dart';

/// LeafGuard's AI assistant. Opened either standalone (from the home top
/// bar) or with [scanContext] set -- straight off a results screen, so the
/// farmer can ask follow-up questions about the exact diagnosis they're
/// looking at without repeating it themselves.
///
/// Always talks in the app's current language: every request to the
/// backend carries the selected language code/name, and the system prompt
/// on the server instructs the model to reply in it.
class ChatScreen extends StatefulWidget {
  final ScanResult? scanContext;
  const ChatScreen({super.key, this.scanContext});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chat = context.read<ChatProvider>();
      chat.reset();
      if (widget.scanContext != null) {
        chat.seedWithScanResult(widget.scanContext!, tr: context.tr);
      } else {
        chat.seedWithWelcome(context.tr('chatWelcomeMessage'));
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppConstants.animMedium,
        curve: Curves.easeOut,
      );
    });
  }

  void _send([String? preset]) {
    final locale = context.read<LocaleProvider>();
    final text = preset ?? _inputController.text;
    if (text.trim().isEmpty) return;
    _inputController.clear();
    context.read<ChatProvider>().sendMessage(
          text,
          languageCode: locale.languageCode,
          languageName: AppLanguages.byCode(locale.languageCode).englishName,
          location: locale.location,
          scanContext: widget.scanContext,
        );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final sending = chat.status == ChatStatus.sending;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDeep]),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.textOnPrimary, size: 16),
            ),
            const SizedBox(width: AppConstants.space12),
            Text(context.tr('aiAssistantTitle')),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!chat.isConfigured)
              _NotConfiguredBanner(text: context.tr('aiNotConfigured')),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.space16,
                  AppConstants.space16,
                  AppConstants.space16,
                  AppConstants.space8,
                ),
                itemCount: chat.messages.length + (sending ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i >= chat.messages.length) return const ChatTypingBubble();
                  return ChatBubble(message: chat.messages[i]);
                },
              ),
            ),
            if (chat.messages.length <= 1 && widget.scanContext != null)
              _QuickPrompts(onTap: _send, scanContext: widget.scanContext!),
            if (chat.status == ChatStatus.error)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
                child: Text(
                  chat.errorMessage == 'not_configured'
                      ? context.tr('aiNotConfigured')
                      : context.tr('chatErrorGeneric'),
                  style: AppTextStyles.body.copyWith(color: AppColors.error),
                ),
              ),
            _InputBar(
              controller: _inputController,
              enabled: chat.isConfigured && !sending,
              onSend: () => _send(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotConfiguredBanner extends StatelessWidget {
  final String text;
  const _NotConfiguredBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.space12),
      color: AppColors.accent.withOpacity(0.12),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 18),
          const SizedBox(width: AppConstants.space8),
          Expanded(child: Text(text, style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}

class _QuickPrompts extends StatelessWidget {
  final void Function(String) onTap;
  final ScanResult scanContext;
  const _QuickPrompts({required this.onTap, required this.scanContext});

  @override
  Widget build(BuildContext context) {
    final prompts = scanContext.diagnosis.isHealthy
        ? [context.tr('chatQuickKeepHealthy'), context.tr('chatQuickPreventFuture')]
        : [
            context.tr('chatQuickCause'),
            context.tr('chatQuickOrganicFirst'),
            context.tr('chatQuickSpreadRisk'),
          ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.space16, 0, AppConstants.space16, AppConstants.space8),
      child: Wrap(
        spacing: AppConstants.space8,
        runSpacing: AppConstants.space8,
        children: prompts
            .map(
              (p) => ActionChip(
                label: Text(p, style: AppTextStyles.caption),
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.divider),
                onPressed: () => onTap(p),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.enabled, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.space16,
        AppConstants.space8,
        AppConstants.space16,
        AppConstants.space16,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: context.tr('chatInputHint'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.space8),
          InkWell(
            onTap: enabled ? onSend : null,
            customBorder: const CircleBorder(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDeep]),
                boxShadow: enabled
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 6))]
                    : null,
              ),
              child: Opacity(
                opacity: enabled ? 1 : 0.5,
                child: const Icon(Icons.arrow_upward_rounded, color: AppColors.textOnPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
