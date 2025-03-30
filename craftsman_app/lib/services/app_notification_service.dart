import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:craftsman_app/services/email_service.dart';

class AppNotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final EmailService _emailService;

  AppNotificationService({
    required EmailService emailService,
    FirebaseMessaging? firebaseMessaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _emailService = emailService,
        _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance,
        _localNotifications = localNotifications ?? 
            FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize Firebase messaging
    await _firebaseMessaging.requestPermission();
    
    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings),
    );
  }

  Future<void> sendApprovalEmail({
    required String email,
    required bool isApproved,
    String? reason,
  }) async {
    try {
      final userName = email.split('@').first;
      await _emailService.sendApprovalNotification(
        email: email,
        userName: userName,
        isApproved: isApproved,
        rejectionReason: reason,
      );
    } catch (e) {
      throw Exception('Failed to send approval email: $e');
    }
  }

  Future<void> sendPushNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'craftsman_channel',
      'Craftsman Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    await _localNotifications.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }
}