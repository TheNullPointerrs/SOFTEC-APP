class UserModel {
  final String uid;
  final String name;
  final String email;
  final int moodStreak;
  final bool notificationsEnabled;
  final String theme;
  final String createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.moodStreak,
    required this.notificationsEnabled,
    required this.theme,
    required this.createdAt,
  });

  // Convert UserModel to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'moodStreak': moodStreak,
      'createdAt': createdAt,
      'notificationsEnabled': notificationsEnabled,
      'theme': theme,
    };
  }

  // Factory method to create a UserModel from a Firestore document map
  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      moodStreak: map['moodStreak'] ?? 0,
      notificationsEnabled: map['notificationsEnabled'] ?? false,
      theme: map['theme'] ?? 'light',
      createdAt: map['createdAt'] ?? '',
    );
  }
}
