import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app_strings.dart';

/// Holds the farmer's chosen language and persists it locally (Hive), the
/// same offline-first storage the rest of the app already uses -- language
/// choice is a device setting, not something worth a network round trip.
class LocaleProvider extends ChangeNotifier {
  static const String _boxName = 'app_settings';
  static const String _key = 'language_code';

  String _languageCode = 'en';
  String get languageCode => _languageCode;

  /// Reads the saved language, if any. Safe to call even if the settings
  /// box can't be opened for some reason -- the app just stays in English
  /// rather than failing to start.
  Future<void> load() async {
    try {
      final box = await Hive.openBox(_boxName);
      final saved = box.get(_key) as String?;
      if (saved != null) {
        _languageCode = saved;
      }
    } catch (_) {
      // Keep the default; language selection isn't critical-path.
    }
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (code == _languageCode) return;
    _languageCode = code;
    notifyListeners();
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_key, code);
    } catch (_) {
      // Selection still applies for this session even if it can't be saved.
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
