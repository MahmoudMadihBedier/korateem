import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IBookingService {
  Future<void> bookField(String fieldId, String userId, String time);
  Stream<QuerySnapshot> getBookingsForField(String fieldId);
}

class BookingService implements IBookingService {
  final CollectionReference bookings = FirebaseFirestore.instance.collection(
    'bookings',
  );

  @override
  Future<void> bookField(String fieldId, String userId, String time) async {
    await bookings.add({
      'fieldId': fieldId,
      'userId': userId,
      'time': time,
      'status': 'pending',
    });
  }

  @override
  Stream<QuerySnapshot> getBookingsForField(String fieldId) {
    return bookings.where('fieldId', isEqualTo: fieldId).snapshots();
  }
}
