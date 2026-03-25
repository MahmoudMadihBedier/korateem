import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IOwnerService {
  Future<void> addStadiumProfile(
    String ownerId,
    Map<String, dynamic> stadiumData,
  );
  Future<void> addStadiumPhotos(String stadiumId, List<String> photoUrls);
  Future<void> updateStadiumDescription(String stadiumId, String description);
  Future<void> setStadiumAvailability(
    String stadiumId,
    List<Map<String, dynamic>> busyTimes,
    List<Map<String, dynamic>> freeTimes,
  );
  Stream<QuerySnapshot> getOwnerStadiums(String ownerId);
  Stream<QuerySnapshot> getBookings(String stadiumId);
  Future<void> contactTeam(String bookingId, String message);
  Future<void> acceptBooking(String bookingId);
  Future<void> rejectBooking(String bookingId, String reason);
}

class OwnerService implements IOwnerService {
  final CollectionReference stadiums = FirebaseFirestore.instance.collection(
    'stadiums',
  );
  final CollectionReference bookings = FirebaseFirestore.instance.collection(
    'bookings',
  );
  final CollectionReference chats = FirebaseFirestore.instance.collection(
    'chats',
  );

  @override
  Future<void> addStadiumProfile(
    String ownerId,
    Map<String, dynamic> stadiumData,
  ) async {
    await stadiums.add({...stadiumData, 'ownerId': ownerId});
  }

  @override
  Future<void> addStadiumPhotos(
    String stadiumId,
    List<String> photoUrls,
  ) async {
    if (stadiumId.trim().isEmpty) {
      throw ArgumentError('stadiumId must not be empty');
    }
    await stadiums.doc(stadiumId).update({'photos': photoUrls});
  }

  @override
  Future<void> updateStadiumDescription(
    String stadiumId,
    String description,
  ) async {
    if (stadiumId.trim().isEmpty) {
      throw ArgumentError('stadiumId must not be empty');
    }
    await stadiums.doc(stadiumId).update({'description': description});
  }

  @override
  Future<void> setStadiumAvailability(
    String stadiumId,
    List<Map<String, dynamic>> busyTimes,
    List<Map<String, dynamic>> freeTimes,
  ) async {
    if (stadiumId.trim().isEmpty) {
      throw ArgumentError('stadiumId must not be empty');
    }
    await stadiums.doc(stadiumId).update({
      'busyTimes': busyTimes,
      'freeTimes': freeTimes,
    });
  }

  @override
  Stream<QuerySnapshot> getOwnerStadiums(String ownerId) {
    return stadiums.where('ownerId', isEqualTo: ownerId).snapshots();
  }

  @override
  Stream<QuerySnapshot> getBookings(String stadiumId) {
    return bookings.where('stadiumId', isEqualTo: stadiumId).snapshots();
  }

  @override
  Future<void> contactTeam(String bookingId, String message) async {
    await chats.add({
      'bookingId': bookingId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> acceptBooking(String bookingId) async {
    if (bookingId.trim().isEmpty) {
      throw ArgumentError('bookingId must not be empty');
    }
    await bookings.doc(bookingId).set({
      'status': 'accepted',
      'rejectionReason': FieldValue.delete(),
      'acceptedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> rejectBooking(String bookingId, String reason) async {
    if (bookingId.trim().isEmpty) {
      throw ArgumentError('bookingId must not be empty');
    }
    final r = reason.trim();
    if (r.isEmpty) {
      throw ArgumentError('reason must not be empty');
    }
    await bookings.doc(bookingId).set({
      'status': 'rejected',
      'rejectionReason': r,
      'rejectedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
