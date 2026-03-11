import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String fieldId;
  final String userId;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final DateTime bookingDate;
  final String timeSlot; // e.g., "14:00-15:00"
  final double totalPrice;
  final int numberOfPlayers;
  final DateTime createdAt;
  final String? cancelledReason;

  BookingModel({
    required this.bookingId,
    required this.fieldId,
    required this.userId,
    required this.status,
    required this.bookingDate,
    required this.timeSlot,
    required this.totalPrice,
    this.numberOfPlayers = 0,
    required this.createdAt,
    this.cancelledReason,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      bookingId: doc.id,
      fieldId: data['fieldId'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'pending',
      bookingDate:
          (data['bookingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      numberOfPlayers: data['numberOfPlayers'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cancelledReason: data['cancelledReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fieldId': fieldId,
      'userId': userId,
      'status': status,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'timeSlot': timeSlot,
      'totalPrice': totalPrice,
      'numberOfPlayers': numberOfPlayers,
      'createdAt': Timestamp.fromDate(createdAt),
      'cancelledReason': cancelledReason,
    };
  }
}
