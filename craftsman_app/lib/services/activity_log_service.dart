import 'package:craftsman_app/models/activity_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activityLogServiceProvider = Provider((ref) => ActivityLogService());

class ActivityLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logActivity({
    required ActivityType activityType,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('activityLogs').add({
      'userId': currentUser.uid,
      'userEmail': currentUser.email,
      'activityType': activityType.index,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
      if (metadata != null) 'metadata': metadata,
    });
  }

  Stream<List<ActivityLog>> getActivityLogs({int limit = 50}) {
    return _firestore
        .collection('activityLogs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityLog.fromFirestore(doc))
            .toList());
  }

  Stream<List<ActivityLog>> getUserActivityLogs(String userId, {int limit = 20}) {
    return _firestore
        .collection('activityLogs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityLog.fromFirestore(doc))
            .toList());
  }
}