import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craftsman_app/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserData(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'phone': user.phone,
      'userType': user.userType.index,
      'craft': user.craft,
      'location': user.location,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUser?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    
    return AppUser(
      uid: uid,
      email: doc['email'],
      phone: doc['phone'],
      userType: UserType.values[doc['userType']],
      craft: doc['craft'],
      location: doc['location'],
    );
  }

  Stream<AppUser?> streamUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser(
        uid: uid,
        email: doc['email'],
        phone: doc['phone'],
        userType: UserType.values[doc['userType']],
        craft: doc['craft'],
        location: doc['location'],
      );
    });
  }
}