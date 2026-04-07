class MatchEntity {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final DateTime utcDate;
  final String status;
  final String? score;
  final String leagueName;
  final String? group;

  MatchEntity({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.utcDate,
    required this.status,
    this.score,
    required this.leagueName,
    this.group,
  });
}
