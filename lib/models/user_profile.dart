class UserProfile {
  final String id;
  final String? name;
  final String? email;
  final List<String> preferredCrops;

  const UserProfile({
    required this.id,
    this.name,
    this.email,
    this.preferredCrops = const [],
  });
}
