import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_model.dart';

abstract class MatchesLocalDataSource {
  Future<void> cacheMatches(String key, List<MatchModel> matches);
  Future<List<MatchModel>> getCachedMatches(String key);
}

class MatchesLocalDataSourceImpl implements MatchesLocalDataSource {
  final SharedPreferences sharedPreferences;

  MatchesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheMatches(String key, List<MatchModel> matches) async {
    final List<String> jsonList = matches.map((m) => json.encode({
      'id': m.id,
      'homeTeam': m.homeTeam,
      'awayTeam': m.awayTeam,
      'homeTeamLogo': m.homeTeamLogo,
      'awayTeamLogo': m.awayTeamLogo,
      'utcDate': m.utcDate.toIso8601String(),
      'status': m.status,
      'score': m.score,
      'leagueName': m.leagueName,
      'leagueId': m.leagueId,
    })).toList();

    await sharedPreferences.setStringList('matches_$key', jsonList);
    await sharedPreferences.setInt('matches_${key}_time', DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<List<MatchModel>> getCachedMatches(String key) async {
    final jsonList = sharedPreferences.getStringList('matches_$key');
    final cacheTime = sharedPreferences.getInt('matches_${key}_time') ?? 0;

    // Cache expiry: 10 minutes
    if (jsonList == null || DateTime.now().millisecondsSinceEpoch - cacheTime > 600000) {
      return [];
    }

    return jsonList.map((item) {
      final jsonMap = json.decode(item);
      return MatchModel(
        id: jsonMap['id'],
        homeTeam: jsonMap['homeTeam'],
        awayTeam: jsonMap['awayTeam'],
        homeTeamLogo: jsonMap['homeTeamLogo'],
        awayTeamLogo: jsonMap['awayTeamLogo'],
        utcDate: DateTime.parse(jsonMap['utcDate']),
        status: jsonMap['status'],
        score: jsonMap['score'],
        leagueName: jsonMap['leagueName'],
        leagueId: jsonMap['leagueId'],
      );
    }).toList();
  }
}
