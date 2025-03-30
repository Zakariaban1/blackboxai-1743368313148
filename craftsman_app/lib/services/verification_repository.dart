import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:craftsman_app/models/user_model.dart';
import 'package:craftsman_app/models/verification_stats.dart';

class VerificationRepository {
  final FirebaseFirestore _firestore;

  VerificationRepository(this._firestore);

  Future<VerificationStats> getVerificationStats({DateTimeRange? dateRange}) async {
    Query query = _firestore.collection('users');
    
    if (dateRange != null) {
      query = query.where('createdAt', 
        isGreaterThanOrEqualTo: dateRange.start)
        .where('createdAt', isLessThanOrEqualTo: dateRange.end);
    }

    final snapshot = await query.get();
    final users = snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();

    final totalUsers = users.length;
    final verifiedUsers = users.where((u) => u.isVerified).length;
    final emailVerified = users.where((u) => u.isEmailVerified).length;
    final manuallyVerified = users.where((u) => u.isManuallyVerified).length;

    return VerificationStats(
      totalUsers: totalUsers,
      verifiedUsers: verifiedUsers,
      emailVerified: emailVerified,
      manuallyVerified: manuallyVerified,
      dateRange: dateRange,
    );
  }

  Stream<List<VerificationLog>> getVerificationLogs({DateTimeRange? dateRange}) {
    Query query = _firestore.collection('verification_logs')
      .orderBy('timestamp', descending: true)
      .limit(50);

    if (dateRange != null) {
      query = query.where('timestamp', 
        isGreaterThanOrEqualTo: dateRange.start)
        .where('timestamp', isLessThanOrEqualTo: dateRange.end);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => VerificationLog.fromFirestore(doc))
        .toList());
  }
}