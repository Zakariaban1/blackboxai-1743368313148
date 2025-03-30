import 'package:cloud_firestore/cloud_firestore.dart';

class UserPreference {
  final String userId;
  final List<String> preferredCrafts;
  final int preferredDifficulty;
  final List<String> viewedContentIds;
  final DateTime lastUpdated;

  UserPreference({
    required this.userId,
    required this.preferredCrafts,
    required this.preferredDifficulty,
    required this.viewedContentIds,
    required this.lastUpdated,
  });

  factory UserPreference.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserPreference(
      userId: doc.id,
      preferredCrafts: List<String>.from(data['preferredCrafts']),
      preferredDifficulty: data['preferredDifficulty'],
      viewedContentIds: List<String>.from(data['viewedContentIds']),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'preferredCrafts': preferredCrafts,
      'preferredDifficulty': preferredDifficulty,
      'viewedContentIds': viewedContentIds,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}