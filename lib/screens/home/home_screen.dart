import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../scan/scan_screen.dart';
import '../history/history_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final tabs = [
      DashboardTab(onScanTap: _openScan),
      const HistoryScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: tabs[_tabIndex]),
      bottomNavigationBar: LeafGuardBottomNavBar(
        currentIndex: _tabIndex,
        onTabSelected: (i) => setState(() => _tabIndex = i),
        onScanPressed: _openScan,
      ),
    );
  }
}
