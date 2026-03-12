import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatsModel {
  final String userId;
  final int matchesPlayed;
  final int friendsCount;
  final int bookingsCount;
  final double winRate;
  final List<Map<String, dynamic>> achievements;

  UserStatsModel({
    required this.userId,
    this.matchesPlayed = 0,
    this.friendsCount = 0,
    this.bookingsCount = 0,
    this.winRate = 0.0,
    this.achievements = const [],
  });

  factory UserStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserStatsModel(
      userId: doc.id,
      matchesPlayed: data['matchesPlayed'] ?? 0,
      friendsCount: data['friendsCount'] ?? 0,
      bookingsCount: data['bookingsCount'] ?? 0,
      winRate: (data['winRate'] ?? 0.0).toDouble(),
      achievements: List<Map<String, dynamic>>.from(data['achievements'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matchesPlayed': matchesPlayed,
      'friendsCount': friendsCount,
      'bookingsCount': bookingsCount,
      'winRate': winRate,
      'achievements': achievements,
    };
  }
}
