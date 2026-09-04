/// A single selectable language: the code used to look up strings, its own
/// name written in itself (so a farmer finds their language by sight, not
/// by reading English), and the English name shown underneath as a second
/// reference point.
class AppLanguage {
  final String code;
  final String nativeName;
  final String englishName;

  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
  });
}

/// Languages LeafGuard covers, prioritized around India's major
/// crop-growing states rather than population size alone -- Punjabi and
/// Marathi matter here as much as Bengali does.
class AppLanguages {
  AppLanguages._();

  static const List<AppLanguage> supported = [
    AppLanguage(code: 'en', nativeName: 'English', englishName: 'English'),
    AppLanguage(code: 'hi', nativeName: 'हिन्दी', englishName: 'Hindi'),
    AppLanguage(code: 'mr', nativeName: 'मराठी', englishName: 'Marathi'),
    AppLanguage(code: 'te', nativeName: 'తెలుగు', englishName: 'Telugu'),
    AppLanguage(code: 'ta', nativeName: 'தமிழ்', englishName: 'Tamil'),
    AppLanguage(code: 'bn', nativeName: 'বাংলা', englishName: 'Bengali'),
    AppLanguage(code: 'gu', nativeName: 'ગુજરાતી', englishName: 'Gujarati'),
    AppLanguage(code: 'kn', nativeName: 'ಕನ್ನಡ', englishName: 'Kannada'),
    AppLanguage(code: 'pa', nativeName: 'ਪੰਜਾਬੀ', englishName: 'Punjabi'),
  ];

  static AppLanguage byCode(String code) => supported.firstWhere(
        (l) => l.code == code,
        orElse: () => supported.first,
      );
}
