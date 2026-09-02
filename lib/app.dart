import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/constants/app_constants.dart';
import 'services/tflite_service.dart';
import 'services/local_storage_service.dart';
import 'services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/history_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';

class LeafGuardApp extends StatefulWidget {
  const LeafGuardApp({super.key});

  @override
  State<LeafGuardApp> createState() => _LeafGuardAppState();
}

class _LeafGuardAppState extends State<LeafGuardApp> {
  final _tfliteService = TFLiteService();
  final _localStorageService = LocalStorageService();
  SupabaseService? _supabaseService;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _supabaseService = SupabaseService();
    await _localStorageService.init();
    await _tfliteService.loadModel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeafGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SplashScreen();
          }
          if (snapshot.hasError) {
            return _InitErrorScreen(error: snapshot.error.toString());
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AuthProvider(_supabaseService!)),
              ChangeNotifierProvider(
                create: (_) => ScanProvider(_tfliteService, _localStorageService, _supabaseService!),
              ),
              ChangeNotifierProvider(create: (_) => HistoryProvider(_localStorageService)),
            ],
            child: const HomeScreen(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }
}

/// Shown if the model or a required service fails to load at startup --
/// most commonly because the .tflite/labels.txt files aren't bundled yet.
/// See the app README for where those files need to go.
class _InitErrorScreen extends StatelessWidget {
  final String error;
  const _InitErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.severe, size: 40),
              const SizedBox(height: AppConstants.space16),
              Text('Couldn\u2019t start LeafGuard', style: AppTextStyles.title, textAlign: TextAlign.center),
              const SizedBox(height: AppConstants.space8),
              Text(
                'Make sure leafguard_v1_int8.tflite and labels.txt are in assets/model/. See the app README for setup steps.\n\n$error',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
