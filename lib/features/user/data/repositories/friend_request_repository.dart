import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_request_model.dart';

abstract class IFriendRequestRepository {
  Future<void> sendFriendRequest(
    String senderId,
    String recipientId,
    String senderName,
    String senderImage,
  );
  Future<void> acceptFriendRequest(
    String requestId,
    String senderId,
    String recipientId,
  );
  Future<void> rejectFriendRequest(String requestId);
  Stream<List<FriendRequestModel>> getPendingRequests(String userId);
  Future<bool> checkIfFriendRequestExists(String senderId, String recipientId);
}

class FriendRequestRepository implements IFriendRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> sendFriendRequest(
    String senderId,
    String recipientId,
    String senderName,
    String senderImage,
  ) async {
    try {
      if (senderId.trim().isEmpty || recipientId.trim().isEmpty) {
        throw ArgumentError('senderId/recipientId must not be empty');
      }
      if (senderId == recipientId) {
        throw ArgumentError('senderId and recipientId must be different');
      }

      // Check if request already exists
      final exists = await checkIfFriendRequestExists(senderId, recipientId);
      if (exists) {
        throw Exception('Friend request already exists');
      }

      await _firestore.collection('friendRequests').add({
        'senderId': senderId,
        'senderName': senderName,
        'senderImage': senderImage,
        'recipientId': recipientId,
        'sentAt': Timestamp.now(),
        'status': 'pending',
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> acceptFriendRequest(
    String requestId,
    String senderId,
    String recipientId,
  ) async {
    try {
      if (requestId.trim().isEmpty ||
          senderId.trim().isEmpty ||
          recipientId.trim().isEmpty) {
        throw ArgumentError('requestId/senderId/recipientId must not be empty');
      }

      final batch = _firestore.batch();

      // Update request status
      final requestRef = _firestore.collection('friendRequests').doc(requestId);
      batch.update(requestRef, {
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Add each other to friends list using atomic arrayUnion to avoid overwrites.
      final senderRef = _firestore.collection('users').doc(senderId);
      final recipientRef = _firestore.collection('users').doc(recipientId);

      batch.set(senderRef, {
        'friends': FieldValue.arrayUnion([recipientId]),
      }, SetOptions(merge: true));

      batch.set(recipientRef, {
        'friends': FieldValue.arrayUnion([senderId]),
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      if (requestId.trim().isEmpty) {
        throw ArgumentError('requestId must not be empty');
      }
      await _firestore.collection('friendRequests').doc(requestId).update({
        'status': 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<FriendRequestModel>> getPendingRequests(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('recipientId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FriendRequestModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<bool> checkIfFriendRequestExists(
    String senderId,
    String recipientId,
  ) async {
    try {
      final query = await _firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: senderId)
          .where('recipientId', isEqualTo: recipientId)
          .where('status', isEqualTo: 'pending')
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
