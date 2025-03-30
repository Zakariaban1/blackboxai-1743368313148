import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: kIsWeb
            ? const FirebaseOptions(
                apiKey: "YOUR_WEB_API_KEY",
                appId: "YOUR_WEB_APP_ID",
                messagingSenderId: "YOUR_WEB_SENDER_ID",
                projectId: "craftsman-app",
                storageBucket: "craftsman-app.appspot.com",
              )
            : null,
      );
    } catch (e) {
      throw Exception("Failed to initialize Firebase: $e");
    }
  }
}