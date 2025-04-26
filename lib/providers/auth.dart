import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/services/auth.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
