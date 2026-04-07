import '../../domain/entities/match_entity.dart';

abstract class IMatchesRepository {
  Future<List<MatchEntity>> getAllMatches();
  Future<List<MatchEntity>> getMatchesByLeague(int leagueId);
}
