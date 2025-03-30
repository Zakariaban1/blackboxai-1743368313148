import 'package:cloud_firestore/cloud_firestore.dart';

class JobRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String? message;
  final String status;
  final DateTime createdAt;
  final String? craft;
  final String? location;

  JobRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.message,
    this.status = 'pending',
    required this.createdAt,
    this.craft,
    this.location,
  });

  factory JobRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobRequest(
      id: doc.id,
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      message: data['message'],
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      craft: data['craft'],
      location: data['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'craft': craft,
      'location': location,
    };
  }
}