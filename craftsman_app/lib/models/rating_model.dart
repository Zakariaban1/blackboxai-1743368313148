import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String jobId;
  final String craftsmanId;
  final String clientId;
  final int stars;
  final String? comment;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.jobId,
    required this.craftsmanId,
    required this.clientId,
    required this.stars,
    this.comment,
    required this.createdAt,
  });

  factory Rating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Rating(
      id: doc.id,
      jobId: data['jobId'],
      craftsmanId: data['craftsmanId'],
      clientId: data['clientId'],
      stars: data['stars'],
      comment: data['comment'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'craftsmanId': craftsmanId,
      'clientId': clientId,
      'stars': stars,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}