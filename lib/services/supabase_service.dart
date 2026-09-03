import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase for optional auth and cloud sync of scan
/// history. Every call here is treated as best-effort -- the core scanning
/// flow must remain fully usable even if this service is unreachable or
/// unconfigured, since offline reliability is the app's whole premise.
class SupabaseService {
  SupabaseService({required this.enabled});

  final bool enabled;

  SupabaseClient? get _client => enabled ? Supabase.instance.client : null;

  User? get currentUser => _client?.auth.currentUser;
  bool get isSignedIn => currentUser != null;

  Future<AuthResponse> signUp({required String email, required String password}) {
    if (!enabled) return Future.error(StateError('Supabase is not configured'));
    return _client!.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn({required String email, required String password}) {
    if (!enabled) return Future.error(StateError('Supabase is not configured'));
    return _client!.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => enabled ? _client!.auth.signOut() : Future.value();

  /// Best-effort sync -- swallows errors so a flaky or absent connection
  /// never blocks or fails a scan.
  Future<void> syncScan(Map<String, dynamic> scanData) async {
    if (!enabled) return;
    try {
      await _client!.from('scans').insert(scanData);
    } catch (_) {
      // Intentionally ignored -- sync is opportunistic, not required.
    }
  }
}
