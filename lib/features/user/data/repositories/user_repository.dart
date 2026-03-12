import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class IUserRepository {
  Future<UserModel> getUser(String userId);
  Future<List<UserModel>> getUsersByIds(List<String> userIds);
  Future<void> updateUserProfile(UserModel user);
  Stream<List<UserModel>> searchUsers(String query);
  Stream<List<UserModel>> getAllUsers();
  Future<void> rateUser(String userId, double rating);
}

class UserRepository implements IUserRepository {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  @override
  Future<UserModel> getUser(String userId) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId must not be empty');
    }
    final doc = await users.doc(userId).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('User profile not found');
    }
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    final ids = userIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (ids.isEmpty) return const [];

    // Firestore `whereIn` max is 10, and teams are 5 members.
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snapshot.docs.map((d) => UserModel.fromFirestore(d)).toList();
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    if (user.id.trim().isEmpty) {
      throw ArgumentError('user.id must not be empty');
    }
    await users.doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  @override
  Stream<List<UserModel>> getAllUsers() {
    return users.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
    );
  }

  @override
  Stream<List<UserModel>> searchUsers(String query) {
    final q = query.trim();
    if (q.isEmpty) {
      return const Stream<List<UserModel>>.empty();
    }

    // Client-side filter to support legacy/partial schemas (e.g. missing `name`)
    // without requiring specific Firestore indexes.
    final lower = q.toLowerCase();
    return users.snapshots().map((snapshot) {
      final all = snapshot.docs.map((doc) => UserModel.fromFirestore(doc));
      return all.where((u) => u.id.isNotEmpty).where((u) {
        final name = u.name.toLowerCase();
        final email = u.email.toLowerCase();
        final phone = u.phone.toLowerCase();
        return name.contains(lower) ||
            email.contains(lower) ||
            phone.contains(lower);
      }).toList();
    });
  }

  @override
  Future<void> rateUser(String userId, double rating) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId must not be empty');
    }
    await users.doc(userId).update({'rating': rating});
  }
}
