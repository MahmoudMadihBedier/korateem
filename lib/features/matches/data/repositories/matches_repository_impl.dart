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
  Future<List<MatchEntity>> getMatchesByLeague(int leagueId) async {
    try {
      final matches = await remoteDataSource.getMatchesByLeague(leagueId);
      return matches;
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
}
