import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IUserService {
  Future<DocumentSnapshot> getUserProfile(String uid);
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);
}

class UserService implements IUserService {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  @override
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await users.doc(uid).get();
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await users.doc(uid).update(data);
  }
}
