import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craftsman_app/models/approval_model.dart';
import 'package:craftsman_app/models/user_model.dart';
import 'package:craftsman_app/services/notification_service.dart';

class UserApprovalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<void> submitForApproval(AppUser user) async {
    await _firestore.collection('userApprovals').add({
      'userId': user.uid,
      'email': user.email,
      'userType': user.userType.index,
      'status': ApprovalStatus.pending.index,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> approveUser(String approvalId, String adminId) async {
    final approvalDoc = await _firestore.collection('userApprovals').doc(approvalId).get();
    final userId = approvalDoc['userId'];
    final userEmail = approvalDoc['email'];

    await _firestore.collection('users').doc(userId).update({
      'isApproved': true,
    });

    await _firestore.collection('userApprovals').doc(approvalId).update({
      'status': ApprovalStatus.approved.index,
      'reviewedBy': adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
    });

    // Send approval email
    await _notificationService.sendApprovalEmail(
      email: userEmail,
      isApproved: true,
    );
  }

  Future<void> rejectUser(String approvalId, String adminId, String reason) async {
    final approvalDoc = await _firestore.collection('userApprovals').doc(approvalId).get();
    final userEmail = approvalDoc['email'];

    await _firestore.collection('userApprovals').doc(approvalId).update({
      'status': ApprovalStatus.rejected.index,
      'reviewedBy': adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
      'rejectionReason': reason,
    });

    // Send rejection email
    await _notificationService.sendApprovalEmail(
      email: userEmail,
      isApproved: false,
      reason: reason,
    );
  }

  Stream<List<UserApproval>> getPendingApprovals() {
    return _firestore
        .collection('userApprovals')
        .where('status', isEqualTo: ApprovalStatus.pending.index)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserApproval.fromFirestore(doc))
            .toList());
  }
}