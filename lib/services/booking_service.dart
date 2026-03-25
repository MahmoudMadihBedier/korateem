import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IBookingService {
  Future<void> createBooking({
    required String stadiumId,
    required String stadiumName,
    required String userId,
    required String teamId,
    required String teamName,
    required String opponentTeamId,
    required String opponentTeamName,
    required List<String> teamMemberIds,
    required String teamCaptainId,
    required List<String> opponentMemberIds,
    required String opponentCaptainId,
    required DateTime date,
    required String time,
    required int durationHours,
    required String endTime,
    required String phone,
  });
  Stream<QuerySnapshot> getBookingsForStadium(String stadiumId);

  Future<void> cancelParticipation({
    required String bookingId,
    required String userId,
    required String reason,
  });
}

class BookingService implements IBookingService {
  final CollectionReference bookings = FirebaseFirestore.instance.collection(
    'bookings',
  );

  @override
  Future<void> createBooking({
    required String stadiumId,
    required String stadiumName,
    required String userId,
    required String teamId,
    required String teamName,
    required String opponentTeamId,
    required String opponentTeamName,
    required List<String> teamMemberIds,
    required String teamCaptainId,
    required List<String> opponentMemberIds,
    required String opponentCaptainId,
    required DateTime date,
    required String time,
    required int durationHours,
    required String endTime,
    required String phone,
  }) async {
    if (stadiumId.trim().isEmpty) {
      throw ArgumentError('stadiumId must not be empty');
    }
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId must not be empty');
    }
    if (teamId.trim().isEmpty || opponentTeamId.trim().isEmpty) {
      throw ArgumentError('teamId/opponentTeamId must not be empty');
    }
    if (teamId.trim() == opponentTeamId.trim()) {
      throw ArgumentError('teamId and opponentTeamId must be different');
    }
    if (time.trim().isEmpty) {
      throw ArgumentError('time must not be empty');
    }
    if (durationHours < 1 || durationHours > 6) {
      throw ArgumentError('durationHours must be between 1 and 6');
    }
    if (endTime.trim().isEmpty) {
      throw ArgumentError('endTime must not be empty');
    }
    final normalizedTeamMembers = teamMemberIds
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    final normalizedOppMembers = opponentMemberIds
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (teamCaptainId.trim().isEmpty || opponentCaptainId.trim().isEmpty) {
      throw ArgumentError('teamCaptainId/opponentCaptainId must not be empty');
    }

    final participantIds = <String>{
      ...normalizedTeamMembers,
      ...normalizedOppMembers,
    }.toList();

    await bookings.add({
      'stadiumId': stadiumId,
      'stadiumName': stadiumName,
      'userId': userId,
      'teamId': teamId,
      'teamName': teamName,
      'opponentTeamId': opponentTeamId,
      'opponentTeamName': opponentTeamName,
      'teamMemberIds': normalizedTeamMembers,
      'teamCaptainId': teamCaptainId.trim(),
      'opponentMemberIds': normalizedOppMembers,
      'opponentCaptainId': opponentCaptainId.trim(),
      'participantIds': participantIds,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'time': time,
      'durationHours': durationHours,
      'endTime': endTime,
      'phone': phone,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'canceledParticipantIds': <String>[],
      'cancellations': <Map<String, dynamic>>[],
    });
  }

  @override
  Stream<QuerySnapshot> getBookingsForStadium(String stadiumId) {
    if (stadiumId.trim().isEmpty) {
      return const Stream<QuerySnapshot>.empty();
    }
    return bookings.where('stadiumId', isEqualTo: stadiumId).snapshots();
  }

  @override
  Future<void> cancelParticipation({
    required String bookingId,
    required String userId,
    required String reason,
  }) async {
    final id = bookingId.trim();
    final uid = userId.trim();
    final r = reason.trim();
    if (id.isEmpty) throw ArgumentError('bookingId must not be empty');
    if (uid.isEmpty) throw ArgumentError('userId must not be empty');
    if (r.isEmpty) throw ArgumentError('reason must not be empty');

    await bookings.doc(id).set({
      'canceledParticipantIds': FieldValue.arrayUnion([uid]),
      'cancellations': FieldValue.arrayUnion([
        {
          'userId': uid,
          'reason': r,
          'at': Timestamp.now(),
        },
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
