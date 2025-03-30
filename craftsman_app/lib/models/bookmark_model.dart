import 'package:cloud_firestore/cloud_firestore.dart';

class Bookmark {
  final String id;
  final String userId;
  final String contentId;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.createdAt,
  });

  factory Bookmark.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Bookmark(
      id: doc.id,
      userId: data['userId'],
      contentId: data['contentId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'contentId': contentId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}