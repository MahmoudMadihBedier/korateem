import 'package:cloud_firestore/cloud_firestore.dart';

class TeamModel {
  final String teamId;
  final String name;
  final String captainId;
  final String captainName;
  final List<String> memberIds;
  final String description;
  final String imageUrl;
  final double rating;
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final DateTime createdAt;

  TeamModel({
    required this.teamId,
    required this.name,
    required this.captainId,
    required this.captainName,
    this.memberIds = const [],
    required this.description,
    required this.imageUrl,
    this.rating = 0.0,
    this.totalMatches = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    required this.createdAt,
  });

  factory TeamModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TeamModel(
      teamId: doc.id,
      name: data['name'] ?? '',
      captainId: data['captainId'] ?? '',
      captainName: data['captainName'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      totalMatches: data['totalMatches'] ?? 0,
      wins: data['wins'] ?? 0,
      losses: data['losses'] ?? 0,
      draws: data['draws'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'captainId': captainId,
      'captainName': captainName,
      'memberIds': memberIds,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'totalMatches': totalMatches,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
