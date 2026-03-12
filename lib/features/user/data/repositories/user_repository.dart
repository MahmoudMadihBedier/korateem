import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class IUserRepository {
  Future<UserModel> getUser(String userId);
  Future<void> updateUserProfile(UserModel user);
  Stream<List<UserModel>> searchUsers(String query);
  Future<void> rateUser(String userId, double rating);
}

class UserRepository implements IUserRepository {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  @override
  Future<UserModel> getUser(String userId) async {
    final doc = await users.doc(userId).get();
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    await users.doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  @override
  Stream<List<UserModel>> searchUsers(String query) {
    return users
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  @override
  Future<void> rateUser(String userId, double rating) async {
    await users.doc(userId).update({'rating': rating});
  }
}
