import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  contentCreated,
  contentViewed,
  quizCompleted,
  userRegistered,
  contentApproved,
  contentRejected,
  userRoleChanged
}

class ActivityLog {
  final String id;
  final String userId;
  final String userEmail;
  final ActivityType activityType;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.activityType,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  factory ActivityLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLog(
      id: doc.id,
      userId: data['userId'],
      userEmail: data['userEmail'],
      activityType: ActivityType.values[data['activityType']],
      description: data['description'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'activityType': activityType.index,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}