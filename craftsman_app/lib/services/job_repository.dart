import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:craftsman_app/models/job_model.dart';

class JobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> createJobRequest(JobRequest request) async {
    final docRef = await _firestore.collection('jobRequests').add(request.toMap());
    
    // Update with generated ID
    await docRef.update({'id': docRef.id});
    
    // Send notification
    await _firebaseMessaging.sendMessage(
      to: '/topics/user_${request.receiverId}',
      data: {
        'type': 'new_request',
        'jobId': docRef.id,
      },
      notification: Notification(
        title: 'New Job Request',
        body: 'You have a new job request for ${request.craft}',
      ),
    );
  }

  Stream<List<JobRequest>> getJobRequests(String userId) {
    return _firestore
        .collection('jobRequests')
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobRequest.fromFirestore(doc))
            .toList());
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    await _firestore
        .collection('jobRequests')
        .doc(jobId)
        .update({'status': status});

    // Get the job request to notify the client
    final doc = await _firestore.collection('jobRequests').doc(jobId).get();
    final request = JobRequest.fromFirestore(doc);

    // Send notification
    await _firebaseMessaging.sendMessage(
      to: '/topics/user_${request.senderId}',
      data: {
        'type': 'status_update',
        'jobId': jobId,
        'status': status,
      },
      notification: Notification(
        title: 'Job Request $status',
        body: 'Your job request has been $status',
      ),
    );
  }
}