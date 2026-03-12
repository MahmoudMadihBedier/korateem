import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String recipientId;
  final DateTime sentAt;
  final String status; // 'pending', 'accepted', 'rejected'

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.recipientId,
    required this.sentAt,
    this.status = 'pending',
  });

  factory FriendRequestModel.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    if (raw is! Map<String, dynamic>) {
      return FriendRequestModel(
        id: doc.id,
        senderId: '',
        senderName: '',
        senderImage: '',
        recipientId: '',
        sentAt: DateTime.now(),
        status: 'pending',
      );
    }

    final data = raw;
    return FriendRequestModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderImage: data['senderImage'] ?? '',
      recipientId: data['recipientId'] ?? '',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'recipientId': recipientId,
      'sentAt': Timestamp.fromDate(sentAt),
      'status': status,
    };
  }
}
