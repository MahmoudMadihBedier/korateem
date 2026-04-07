import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/match_model.dart';

abstract class MatchesRemoteDataSource {
  Future<List<MatchModel>> getMatchesByLeague(int leagueId);
  Future<List<MatchModel>> getAllMatches();
}

class MatchesRemoteDataSourceImpl implements MatchesRemoteDataSource {
  final http.Client client;
  final String? apiKey;

  // For API-Football (RapidAPI)
  static const String baseUrl = 'https://v3.football.api-sports.io';

  MatchesRemoteDataSourceImpl({required this.client, this.apiKey});

  @override
  Future<List<MatchModel>> getMatchesByLeague(int leagueId) async {
    if (apiKey == null || apiKey!.isEmpty) {
      // Return mock data for testing if no API key is provided
      return _getMockMatches(leagueId);
    }

    final response = await client.get(
      Uri.parse('$baseUrl/fixtures?league=$leagueId&next=10'),
      headers: {
        'x-rapidapi-key': apiKey!,
        'x-rapidapi-host': 'v3.football.api-sports.io',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List fixtures = data['response'] ?? [];
      return fixtures.map((f) => MatchModel.fromApiFootball(f)).toList();
    } else {
      throw Exception('Failed to load matches for league $leagueId');
    }
  }

  @override
  Future<List<MatchModel>> getAllMatches() async {
    final leagues = [
      39, // Premier League
      140, // La Liga
      233, // Egyptian Premier League
      2, // Champions League
      12, // CAF Champions League
    ];

    final results = await Future.wait(
      leagues.map((leagueId) => getMatchesByLeague(leagueId).catchError((e) {
        // Log error and return empty list to not break everything if one league fails
        return <MatchModel>[];
      }))
    );

    return results.expand((x) => x).toList();
  }

  List<MatchModel> _getMockMatches(int leagueId) {
    final now = DateTime.now();
    final leagueNames = {
      233: 'الدوري المصري الممتاز',
      140: 'الدوري الإسباني',
      39: 'الدوري الإنجليزي',
      2: 'دوري أبطال أوروبا',
      12: 'دوري أبطال أفريقيا',
    };
    final leagueName = leagueNames[leagueId] ?? 'دوري غير معروف';

    return [
      MatchModel(
        id: '${leagueId}_1',
        homeTeam: 'الأهلي',
        awayTeam: 'الزمالك',
        homeTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/a/a7/Al_Ahly_SC_logo.svg',
        awayTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/d/d4/Zamalek_SC_logo.svg',
        utcDate: now.add(const Duration(hours: 2)),
        status: 'NS',
        leagueName: leagueName,
      ),
      MatchModel(
        id: '${leagueId}_2',
        homeTeam: 'ريال مدريد',
        awayTeam: 'برشلونة',
        homeTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/5/56/Real_Madrid_CF.svg',
        awayTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/4/47/FC_Barcelona_%28logo%29.svg',
        utcDate: now.add(const Duration(days: 1)),
        status: 'NS',
        leagueName: leagueName,
      ),
    ];
  }
}
