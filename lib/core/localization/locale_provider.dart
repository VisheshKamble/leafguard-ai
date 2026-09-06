import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app_strings.dart';

/// Holds the farmer's chosen language and persists it locally (Hive), the
/// same offline-first storage the rest of the app already uses -- language
/// choice is a device setting, not something worth a network round trip.
class LocaleProvider extends ChangeNotifier {
  static const String _boxName = 'app_settings';
  static const String _languageKey = 'language_code';
  static const String _locationKey = 'location';
  static const String _onboardingKey = 'onboarding_complete';

  String _languageCode = 'en';
  String get languageCode => _languageCode;

  String? _location;
  String? get location => _location;

  bool _onboardingComplete = false;
  bool get onboardingComplete => _onboardingComplete;

  /// Reads saved language, location, and onboarding status, if any. Safe to
  /// call even if the settings box can't be opened for some reason -- the
  /// app just falls back to defaults rather than failing to start.
  Future<void> load() async {
    try {
      final box = await Hive.openBox(_boxName);
      final savedLanguage = box.get(_languageKey) as String?;
      if (savedLanguage != null) _languageCode = savedLanguage;
      _location = box.get(_locationKey) as String?;
      _onboardingComplete = (box.get(_onboardingKey) as bool?) ?? false;
    } catch (_) {
      // Keep the defaults; none of this is critical-path.
    }
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (code == _languageCode) return;
    _languageCode = code;
    notifyListeners();
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_languageKey, code);
    } catch (_) {
      // Selection still applies for this session even if it can't be saved.
    }
  }

  Future<void> setLocation(String? location) async {
    _location = (location == null || location.trim().isEmpty) ? null : location.trim();
    notifyListeners();
    try {
      final box = await Hive.openBox(_boxName);
      if (_location == null) {
        await box.delete(_locationKey);
      } else {
        await box.put(_locationKey, _location);
      }
    } catch (_) {
      // Non-critical; kept for this session either way.
    }
  }

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    notifyListeners();
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_onboardingKey, true);
    } catch (_) {
      // If this fails to persist, the setup screen just shows again next
      // launch -- annoying but harmless.
    }
  }
}

/// `context.tr('key')` looks up the string for the current language, with
/// English as the fallback. Kept as a context extension (rather than a
/// standalone function) so every widget can reach it without threading a
/// translator object through constructors.
extension AppLocalizationX on BuildContext {
  String tr(String key) {
    final code = watch<LocaleProvider>().languageCode;
    return AppStrings.t(code, key);
  }
}
