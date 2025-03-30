import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  final NotificationService _notificationService = NotificationService();

  Future<UserCredential> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Update device token
    final token = await _notificationService.getDeviceToken();
    if (token != null) {
      await UserRepository().updateDeviceToken(userCredential.user!.uid, token);
    }
    
    return userCredential;
  }

  Future<UserCredential> signUpWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}