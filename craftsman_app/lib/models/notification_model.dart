import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  newUser,
  contentCreated,
  pathCreated,
  quizCompleted,
  adminAlert
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? relatedId;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      title: data['title'],
      body: data['body'],
      type: NotificationType.values[data['type']],
      relatedId: data['relatedId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type.index,
      'relatedId': relatedId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}