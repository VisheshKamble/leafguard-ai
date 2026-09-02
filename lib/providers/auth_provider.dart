import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService;

  AuthProvider(this._supabaseService);

  bool isLoading = false;
  String? errorMessage;

  bool get isSignedIn => _supabaseService.isSignedIn;

  Future<bool> signIn(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _supabaseService.signIn(email: email, password: password);
      return true;
    } catch (e) {
      errorMessage = "Couldn't sign in. Check your email and password.";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _supabaseService.signUp(email: email, password: password);
      return true;
    } catch (e) {
      errorMessage = "Couldn't create an account. Try a different email.";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabaseService.signOut();
    notifyListeners();
  }
}
