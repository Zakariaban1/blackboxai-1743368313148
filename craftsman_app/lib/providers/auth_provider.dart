import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/services/auth_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());