class UserModel {
  final String uid;
  final String name;
  final String email;
  final int moodStreak;
  final Map<String, dynamic> preferences;
  final bool notificationsEnabled;
  final String theme;
  final String createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.moodStreak,
    required this.preferences,
    required this.notificationsEnabled,
    required this.theme,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'moodStreak': moodStreak,
      'preferences': preferences,
      'notificationsEnabled': notificationsEnabled,
      'theme': theme,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      moodStreak: map['moodStreak'] ?? 0,
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      notificationsEnabled: map['notificationsEnabled'] ?? false,
      theme: map['theme'] ?? 'light',
      createdAt: map['createdAt'] ?? '',
    );
  }
}
