import 'package:cloud_firestore/cloud_firestore.dart';

class LearningProgress {
  final String id;
  final String userId;
  final String contentId;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final DateTime lastUpdated;

  LearningProgress({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.progress,
    required this.isCompleted,
    required this.lastUpdated,
  });

  factory LearningProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LearningProgress(
      id: doc.id,
      userId: data['userId'],
      contentId: data['contentId'],
      progress: data['progress'].toDouble(),
      isCompleted: data['isCompleted'],
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'contentId': contentId,
      'progress': progress,
      'isCompleted': isCompleted,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}