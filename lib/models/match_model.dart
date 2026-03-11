import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String matchId;
  final String fieldId;
  final String fieldName;
  final String team1Id;
  final String team1Name;
  final String team2Id;
  final String team2Name;
  final DateTime matchDate;
  final String timeSlot;
  final String status; // 'scheduled', 'ongoing', 'completed', 'cancelled'
  final int team1Score;
  final int team2Score;
  final List<String> players;
  final double pricePerPlayer;
  final DateTime createdAt;

  MatchModel({
    required this.matchId,
    required this.fieldId,
    required this.fieldName,
    required this.team1Id,
    required this.team1Name,
    required this.team2Id,
    required this.team2Name,
    required this.matchDate,
    required this.timeSlot,
    this.status = 'scheduled',
    this.team1Score = 0,
    this.team2Score = 0,
    this.players = const [],
    required this.pricePerPlayer,
    required this.createdAt,
  });

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MatchModel(
      matchId: doc.id,
      fieldId: data['fieldId'] ?? '',
      fieldName: data['fieldName'] ?? '',
      team1Id: data['team1Id'] ?? '',
      team1Name: data['team1Name'] ?? '',
      team2Id: data['team2Id'] ?? '',
      team2Name: data['team2Name'] ?? '',
      matchDate: (data['matchDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      status: data['status'] ?? 'scheduled',
      team1Score: data['team1Score'] ?? 0,
      team2Score: data['team2Score'] ?? 0,
      players: List<String>.from(data['players'] ?? []),
      pricePerPlayer: (data['pricePerPlayer'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fieldId': fieldId,
      'fieldName': fieldName,
      'team1Id': team1Id,
      'team1Name': team1Name,
      'team2Id': team2Id,
      'team2Name': team2Name,
      'matchDate': Timestamp.fromDate(matchDate),
      'timeSlot': timeSlot,
      'status': status,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'players': players,
      'pricePerPlayer': pricePerPlayer,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
