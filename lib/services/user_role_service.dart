import 'package:cloud_firestore/cloud_firestore.dart';

class UserRoleService {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  Stream<String?> watchRole(String uid) {
    if (uid.trim().isEmpty) return const Stream.empty();
    return users.doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data is! Map<String, dynamic>) return null;
      final role = (data['role'] ?? '').toString().trim();
      return role.isEmpty ? null : role;
    });
  }

  Future<void> setRoleOnce({required String uid, required String role}) async {
    final normalized = role.trim().toLowerCase();
    if (uid.trim().isEmpty) throw ArgumentError('uid must not be empty');
    if (normalized != 'player' && normalized != 'owner') {
      throw ArgumentError('role must be "player" or "owner"');
    }

    final ref = users.doc(uid);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() as Map<String, dynamic>?;
      final existing = (data?['role'] ?? '').toString().trim().toLowerCase();
      if (existing.isNotEmpty) {
        // Locked: user cannot switch roles after first selection.
        return;
      }
      tx.set(ref, {'role': normalized}, SetOptions(merge: true));
    });
  }
}

