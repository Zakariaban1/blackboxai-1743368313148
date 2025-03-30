import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:craftsman_app/models/user_model.dart';

class VerificationAnalytics {
  final FirebaseAnalytics _analytics;

  VerificationAnalytics(this._analytics);

  Future<void> logVerificationEvent(AppUser user) async {
    await _analytics.logEvent(
      name: 'user_verification',
      parameters: {
        'user_id': user.uid,
        'verification_type': user.isEmailVerified 
            ? 'email' 
            : user.isManuallyVerified 
                ? 'manual' 
                : 'none',
        'user_type': user.userType.name,
      },
    );
  }

  Future<void> logManualVerification(
    String adminId, 
    String userId,
    UserType userType,
  ) async {
    await _analytics.logEvent(
      name: 'manual_verification',
      parameters: {
        'admin_id': adminId,
        'user_id': userId,
        'user_type': userType.name,
      },
    );
  }

  Future<void> logVerificationAttempt(String userId) async {
    await _analytics.logEvent(
      name: 'verification_attempt',
      parameters: {'user_id': userId},
    );
  }
}