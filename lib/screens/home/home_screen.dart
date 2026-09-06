import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/language_selector.dart';
import '../scan/scan_screen.dart';
import '../history/history_screen.dart';
import '../chat/chat_screen.dart';
import '../settings/settings_screen.dart';
import 'dashboard_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  void _openScan() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
  }

  void _openChat() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      DashboardTab(onScanTap: _openScan, onAskAiTap: _openChat),
      const HistoryScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: AppConstants.space16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDeep]),
              ),
              child: const Icon(Icons.eco_rounded, color: AppColors.textOnPrimary, size: 16),
            ),
            const SizedBox(width: AppConstants.space8),
            Text('LeafGuard', style: AppTextStyles.title),
          ],
        ),
        actions: [
          IconButton(
            tooltip: context.tr('aiAssistantTitle'),
            icon: const Icon(Icons.auto_awesome_rounded),
            onPressed: _openChat,
          ),
          IconButton(
            tooltip: context.tr('changeLanguage'),
            icon: const Icon(Icons.translate_rounded),
            onPressed: () => showLanguageSelector(context),
          ),
          IconButton(
            tooltip: context.tr('settingsTitle'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(top: false, child: tabs[_tabIndex]),
      bottomNavigationBar: LeafGuardBottomNavBar(
        currentIndex: _tabIndex,
        onTabSelected: (i) => setState(() => _tabIndex = i),
        onScanPressed: _openScan,
      ),
    );
  }
}
