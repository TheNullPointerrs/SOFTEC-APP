import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? photoURL;
  final String? bio;
  final Map<String, dynamic>? preferences;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL,
    this.bio,
    this.preferences,
  });

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
    String? bio,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
    );
  }
}

class UserNotifier extends StateNotifier<UserProfile?> {
  UserNotifier() : super(null);

  void setUser(UserProfile user) {
    state = user;
  }

  void updateUser(UserProfile updatedUser) {
    state = updatedUser;
  }

  void clearUser() {
    state = null;
  }

  void updatePreferences(Map<String, dynamic> newPreferences) {
    if (state != null) {
      final currentPreferences = state!.preferences ?? {};
      state = state!.copyWith(
        preferences: {...currentPreferences, ...newPreferences},
      );
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserProfile?>((ref) {
  return UserNotifier();
});
