import '../../domain/repositories/matches_repository.dart';
import '../../domain/entities/match_entity.dart';
import '../datasources/matches_remote_datasource.dart';

class MatchesRepositoryImpl implements IMatchesRepository {
  final MatchesRemoteDataSource remoteDataSource;

  static const egyptianLeagueId = 233;
  static const top5LeagueIds = [39, 140, 78, 135, 61];
  static const globalChampIds = [2, 12, 3, 5];

  MatchesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MatchEntity>> getAllMatches() async {
    try {
      final matches = await remoteDataSource.getAllMatches();
      return _sortMatches(matches);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<MatchEntity>> getMatchesByLeague(int leagueId, {DateTime? date}) async {
    try {
      final matches = await remoteDataSource.getMatchesByLeague(leagueId, date: date);
      return _sortMatches(matches);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<MatchEntity>> getMatchesByDate(DateTime date) async {
    try {
      final matches = await remoteDataSource.getMatchesByDate(date);
      return _sortMatches(matches);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  List<MatchEntity> _sortMatches(List<MatchEntity> matches) {
    final sortedList = List<MatchEntity>.from(matches);
    sortedList.sort((a, b) {
      int scoreA = _getPriorityScore(a.leagueId, a.leagueName);
      int scoreB = _getPriorityScore(b.leagueId, b.leagueName);

      if (scoreA != scoreB) {
        return scoreA.compareTo(scoreB);
      }
      return a.utcDate.compareTo(b.utcDate);
    });
    return sortedList;
  }

  int _getPriorityScore(int leagueId, String leagueName) {
    if (leagueId == egyptianLeagueId || leagueName.toLowerCase().contains('egypt')) return 0;
    if (top5LeagueIds.contains(leagueId)) return 1;
    if (globalChampIds.contains(leagueId)) return 2;
    return 3;
  }

  @override
  Future<List<MatchEventEntity>> getMatchEvents(String fixtureId) async {
    try {
      final events = await remoteDataSource.getMatchEvents(fixtureId);
      return events;
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<MatchStatEntity>> getMatchStats(String fixtureId) async {
    try {
      final stats = await remoteDataSource.getMatchStats(fixtureId);
      return stats;
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLeagues() async {
    try {
      return await remoteDataSource.getLeagues();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      return await remoteDataSource.getCountries();
    } catch (e) {
      return [];
    }
  }
}
