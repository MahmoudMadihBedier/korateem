import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/match_model.dart';
import '../../domain/repositories/matches_repository.dart';

abstract class MatchesRemoteDataSource {
  Future<List<MatchModel>> getMatchesByLeague(int leagueId);
  Future<List<MatchModel>> getMatchesByDate(DateTime date);
  Future<List<MatchModel>> getAllMatches();
  Future<List<MatchEventEntity>> getMatchEvents(String fixtureId);
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
      return _getMockMatches(leagueId: leagueId);
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
  Future<List<MatchModel>> getMatchesByDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    if (apiKey == null || apiKey!.isEmpty) {
      return _getMockMatches(date: date);
    }

    // Only get major leagues for the date to avoid too many requests
    final leagues = [39, 140, 233, 2, 12];
    List<MatchModel> matches = [];

    for (var leagueId in leagues) {
      final response = await client.get(
        Uri.parse('$baseUrl/fixtures?date=$dateStr&league=$leagueId'),
        headers: {
          'x-rapidapi-key': apiKey!,
          'x-rapidapi-host': 'v3.football.api-sports.io',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List fixtures = data['response'] ?? [];
        matches.addAll(fixtures.map((f) => MatchModel.fromApiFootball(f)));
      }
    }
    return matches;
  }

  @override
  Future<List<MatchModel>> getAllMatches() async {
    return getMatchesByDate(DateTime.now());
  }

  @override
  Future<List<MatchEventEntity>> getMatchEvents(String fixtureId) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _getMockEvents();
    }

    final response = await client.get(
      Uri.parse('$baseUrl/fixtures/events?fixture=$fixtureId'),
      headers: {
        'x-rapidapi-key': apiKey!,
        'x-rapidapi-host': 'v3.football.api-sports.io',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List events = data['response'] ?? [];
      return events.map((e) => MatchEventEntity(
        time: e['time']['elapsed'] ?? 0,
        teamName: e['team']['name'] ?? '',
        player: e['player']['name'] ?? '',
        type: e['type'] ?? '',
        detail: e['detail'] ?? '',
      )).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  List<MatchModel> _getMockMatches({int? leagueId, DateTime? date}) {
    final now = date ?? DateTime.now();
    final leagueNames = {
      233: 'الدوري المصري الممتاز',
      140: 'الدوري الإسباني',
      39: 'الدوري الإنجليزي',
      2: 'دوري أبطال أوروبا',
      12: 'دوري أبطال أفريقيا',
    };
    final leagueName = (leagueId != null) ? (leagueNames[leagueId] ?? 'دوري غير معروف') : 'الدوري المصري الممتاز';

    return [
      MatchModel(
        id: '${leagueId ?? 0}_1_${now.day}',
        homeTeam: 'الأهلي',
        awayTeam: 'الزمالك',
        homeTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/a/a7/Al_Ahly_SC_logo.svg',
        awayTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/d/d4/Zamalek_SC_logo.svg',
        utcDate: now.copyWith(hour: 20, minute: 0),
        status: 'NS',
        leagueName: leagueName,
      ),
      MatchModel(
        id: '${leagueId ?? 0}_2_${now.day}',
        homeTeam: 'بيراميدز',
        awayTeam: 'المصري',
        homeTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/c/c9/Pyramids_FC_logo.svg',
        awayTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/b/b3/Al-Masry_SC_logo.svg',
        utcDate: now.copyWith(hour: 18, minute: 30),
        status: 'NS',
        leagueName: leagueName,
      ),
    ];
  }

  List<MatchEventEntity> _getMockEvents() {
    return [
      MatchEventEntity(time: 12, teamName: 'الأهلي', player: 'محمد شريف', type: 'Goal', detail: 'Normal Goal'),
      MatchEventEntity(time: 45, teamName: 'الزمالك', player: 'أحمد سيد زيزو', type: 'Card', detail: 'Yellow Card'),
    ];
  }
}
