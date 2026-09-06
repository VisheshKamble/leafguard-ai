class UserProfile {
  final String id;
  final String? name;
  final String? email;
  final String? location;
  final String languageCode;
  final List<String> preferredCrops;

  const UserProfile({
    required this.id,
    this.name,
    this.email,
    this.location,
    this.languageCode = 'en',
    this.preferredCrops = const [],
  });
}
