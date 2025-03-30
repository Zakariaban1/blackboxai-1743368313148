import 'package:cloud_firestore/cloud_firestore.dart';

class ContentAnalytics {
  final String id;
  final String contentId;
  final int views;
  final int completions;
  final double averageScore;
  final DateTime lastUpdated;

  ContentAnalytics({
    required this.id,
    required this.contentId,
    required this.views,
    required this.completions,
    required this.averageScore,
    required this.lastUpdated,
  });

  factory ContentAnalytics.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContentAnalytics(
      id: doc.id,
      contentId: data['contentId'],
      views: data['views'],
      completions: data['completions'],
      averageScore: data['averageScore'].toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'views': views,
      'completions': completions,
      'averageScore': averageScore,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}