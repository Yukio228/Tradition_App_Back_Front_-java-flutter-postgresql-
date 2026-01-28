class UserProfile {
  final String email;
  final String role;
  final String username;
  final String avatarUrl;
  final String themePreference;

  const UserProfile({
    required this.email,
    required this.role,
    required this.username,
    required this.avatarUrl,
    required this.themePreference,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] ?? '',
      role: json['role'] ?? 'USER',
      username: json['username'] ?? 'user',
      avatarUrl: json['avatarUrl'] ?? '',
      themePreference: json['themePreference'] ?? 'DARK',
    );
  }
}

