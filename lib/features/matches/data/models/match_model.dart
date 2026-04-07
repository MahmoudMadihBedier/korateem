import '../../domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  MatchModel({
    required super.id,
    required super.homeTeam,
    required super.awayTeam,
    required super.homeTeamLogo,
    required super.awayTeamLogo,
    required super.utcDate,
    required super.status,
    super.score,
    required super.leagueName,
    super.group,
  });

  // Support for API-Football (RapidAPI) format
  factory MatchModel.fromApiFootball(Map<String, dynamic> json) {
    final teams = json['teams'];
    final goals = json['goals'];
    final fixture = json['fixture'];
    final league = json['league'];

    return MatchModel(
      id: fixture['id']?.toString() ?? '',
      homeTeam: teams['home']['name'] ?? 'Unknown',
      awayTeam: teams['away']['name'] ?? 'Unknown',
      homeTeamLogo: teams['home']['logo'] ?? '',
      awayTeamLogo: teams['away']['logo'] ?? '',
      utcDate: DateTime.fromMillisecondsSinceEpoch(fixture['timestamp'] * 1000),
      status: fixture['status']['short'] ?? 'NS',
      score: goals['home'] != null ? '${goals['home']} - ${goals['away']}' : null,
      leagueName: league['name'] ?? '',
      group: null,
    );
  }
}
