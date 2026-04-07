import '../../domain/repositories/matches_repository.dart';
import '../../domain/entities/match_entity.dart';
import '../datasources/matches_remote_datasource.dart';

class MatchesRepositoryImpl implements IMatchesRepository {
  final MatchesRemoteDataSource remoteDataSource;

  MatchesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MatchEntity>> getAllMatches() async {
    try {
      final matches = await remoteDataSource.getAllMatches();
      return matches;
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<MatchEntity>> getMatchesByLeague(int leagueId, {DateTime? date}) async {
    try {
      final matches = await remoteDataSource.getMatchesByLeague(leagueId, date: date);
      return matches;
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<MatchEntity>> getMatchesByDate(DateTime date) async {
    try {
      final matches = await remoteDataSource.getMatchesByDate(date);
      return matches;
    } catch (e) {
      throw Exception('Repository error: $e');
    }
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
