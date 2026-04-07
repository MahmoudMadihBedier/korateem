import '../../domain/entities/match_entity.dart';

abstract class IMatchesRepository {
  Future<List<MatchEntity>> getAllMatches();
  Future<List<MatchEntity>> getMatchesByLeague(int leagueId, {DateTime? date});
  Future<List<MatchEntity>> getMatchesByDate(DateTime date);
  Future<List<MatchEventEntity>> getMatchEvents(String fixtureId);
  Future<List<Map<String, dynamic>>> getLeagues();
  Future<List<Map<String, dynamic>>> getCountries();
}

class MatchEventEntity {
  final int time;
  final String teamName;
  final String player;
  final String type; // 'Goal', 'Card', 'subst'
  final String detail;

  MatchEventEntity({
    required this.time,
    required this.teamName,
    required this.player,
    required this.type,
    required this.detail,
  });
}
