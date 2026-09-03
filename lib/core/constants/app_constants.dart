class AppConstants {
  AppConstants._();

  // Spacing scale
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;

  static const double radiusSmall = 8;
  static const double radiusMedium = 14;
  static const double radiusLarge = 20;

  static const Duration animFast = Duration(milliseconds: 180);
  static const Duration animMedium = Duration(milliseconds: 320);

  // On-device model
  static const int modelInputSize = 224;
  static const String modelAssetPath = 'assets/model/leafguard_v1_int8.tflite';
  static const String labelsAssetPath = 'assets/model/labels.txt';

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get hasSupabaseConfig =>
      supabaseUrl.startsWith('https://') && supabaseAnonKey.isNotEmpty;
}
