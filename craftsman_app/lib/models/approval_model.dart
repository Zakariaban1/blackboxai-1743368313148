import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craftsman_app/models/learning_content.dart';
import 'package:craftsman_app/models/user_model.dart';

enum ApprovalStatus { pending, approved, rejected }

class ContentApproval {
  final String id;
  final LearningContent content;
  final String submittedBy;
  final ApprovalStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  ContentApproval({
    required this.id,
    required this.content,
    required this.submittedBy,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  factory ContentApproval.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContentApproval(
      id: doc.id,
      content: LearningContent.fromMap(data['content']),
      submittedBy: data['submittedBy'],
      status: ApprovalStatus.values[data['status']],
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      reviewedAt: data['reviewedAt']?.toDate(),
      reviewedBy: data['reviewedBy'],
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content.toMap(),
      'submittedBy': submittedBy,
      'status': status.index,
      'submittedAt': FieldValue.serverTimestamp(),
      'reviewedAt': reviewedAt != null ? FieldValue.serverTimestamp() : null,
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
    };
  }
}

class UserApproval {
  final String id;
  final AppUser user;
  final ApprovalStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  UserApproval({
    required this.id,
    required this.user,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  factory UserApproval.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserApproval(
      id: doc.id,
      user: AppUser.fromFirestore(doc),
      status: ApprovalStatus.values[data['status']],
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      reviewedAt: data['reviewedAt']?.toDate(),
      reviewedBy: data['reviewedBy'],
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.index,
      'submittedAt': FieldValue.serverTimestamp(),
      'reviewedAt': reviewedAt != null ? FieldValue.serverTimestamp() : null,
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
    };
  }
}