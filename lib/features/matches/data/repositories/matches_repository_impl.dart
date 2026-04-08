import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/matches_repository.dart';
import '../datasources/matches_remote_datasource.dart';
import '../datasources/matches_local_datasource.dart';
import 'package:intl/intl.dart';

class MatchesRepositoryImpl implements IMatchesRepository {
  final MatchesRemoteDataSource remoteDataSource;
  final MatchesLocalDataSource localDataSource;

  static const egyptianLeagueId = 233;
  static const top5LeagueIds = [39, 140, 78, 135, 61];
  static const globalChampIds = [2, 12, 3, 5];

  MatchesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<MatchEntity>> getAllMatches() async {
    return getMatchesByDate(DateTime.now());
  }

  @override
  Future<List<MatchEntity>> getMatchesByLeague(
    int leagueId, {
    DateTime? date,
  }) async {
    final cacheKey = _leagueCacheKey(leagueId, date);
    try {
      final cached = await localDataSource.getCachedMatches(cacheKey);
      if (cached.isNotEmpty) return _sortMatches(cached);

      final matches =
          await remoteDataSource.getMatchesByLeague(leagueId, date: date);
      await localDataSource.cacheMatches(cacheKey, matches);
      return _sortMatches(matches);
    } catch (e) {
      final cached = await localDataSource.getCachedMatches(cacheKey);
      if (cached.isNotEmpty) return _sortMatches(cached);
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<MatchEntity>> getMatchesByDate(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyyMMdd').format(date);
      final cached = await localDataSource.getCachedMatches('date_$dateStr');
      if (cached.isNotEmpty) return _sortMatches(cached);

      final matches = await remoteDataSource.getMatchesByDate(date);
      await localDataSource.cacheMatches('date_$dateStr', matches);
      return _sortMatches(matches);
    } catch (e) {
      final dateStr = DateFormat('yyyyMMdd').format(date);
      final cached = await localDataSource.getCachedMatches('date_$dateStr');
      if (cached.isNotEmpty) return _sortMatches(cached);
      throw Exception('Repository error: $e');
    }
  }

  List<MatchEntity> _sortMatches(List<MatchEntity> matches) {
    final sortedList = List<MatchEntity>.from(matches);
    sortedList.sort((a, b) {
      final scoreA = _getPriorityScore(a.leagueId, a.leagueName);
      final scoreB = _getPriorityScore(b.leagueId, b.leagueName);

      if (scoreA != scoreB) {
        return scoreA.compareTo(scoreB);
      }
      return a.utcDate.compareTo(b.utcDate);
    });
    return sortedList;
  }

  int _getPriorityScore(int leagueId, String leagueName) {
    final lower = leagueName.toLowerCase();
    if (leagueId == egyptianLeagueId || lower.contains('egypt')) return 0;
    if (top5LeagueIds.contains(leagueId)) return 1;
    if (globalChampIds.contains(leagueId)) return 2;
    return 3;
  }

  String _leagueCacheKey(int leagueId, DateTime? date) {
    final datePart = date != null ? DateFormat('yyyyMMdd').format(date) : 'next';
    return 'league_${leagueId}_$datePart';
  }

  @override
  Future<List<MatchEventEntity>> getMatchEvents(String fixtureId) async {
    try {
      return await remoteDataSource.getMatchEvents(fixtureId);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<MatchStatEntity>> getMatchStats(String fixtureId) async {
    try {
      return await remoteDataSource.getMatchStats(fixtureId);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLeagues() async {
    try {
      return await remoteDataSource.getLeagues();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      return await remoteDataSource.getCountries();
    } catch (_) {
      return [];
    }
  }
}
