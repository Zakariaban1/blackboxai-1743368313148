import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { craftsman, serviceSeeker, learner, admin }

extension UserTypeExtension on UserType {
  String get name {
    switch (this) {
      case UserType.craftsman:
        return 'Craftsman';
      case UserType.serviceSeeker:
        return 'Service Seeker';
      case UserType.learner:
        return 'Learner';
      case UserType.admin:
        return 'Admin';
    }
  }

  bool get canCreateContent => this == UserType.admin;
  bool get canCreatePaths => this == UserType.admin;
  bool get canViewAnalytics => this == UserType.admin;
  bool get canManageUsers => this == UserType.admin;
}

class AppUser {
  final String uid;
  final String email;
  final String? phone;
  final UserType userType;
  final String? craft;
  final String? location;
  final bool isApproved;
  final bool isEmailVerified;
  final bool isManuallyVerified;
  final String? verifiedBy;
  final DateTime? verificationDate;

  AppUser({
    required this.uid,
    required this.email,
    this.phone,
    required this.userType,
    this.craft,
    this.location,
    this.isApproved = false,
    this.isEmailVerified = false,
    this.isManuallyVerified = false,
    this.verifiedBy,
    this.verificationDate,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'],
      phone: data['phone'],
      userType: UserType.values[data['userType']],
      craft: data['craft'],
      location: data['location'],
      isApproved: data['isApproved'] ?? false,
      isEmailVerified: data['isEmailVerified'] ?? false,
      isManuallyVerified: data['isManuallyVerified'] ?? false,
      verifiedBy: data['verifiedBy'],
      verificationDate: data['verificationDate']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
      'userType': userType.index,
      'craft': craft,
      'location': location,
      'isApproved': isApproved,
      'isEmailVerified': isEmailVerified,
      'isManuallyVerified': isManuallyVerified,
      'verifiedBy': verifiedBy,
      'verificationDate': verificationDate,
    };
  }

  bool get isVerified => isEmailVerified || isManuallyVerified;
}