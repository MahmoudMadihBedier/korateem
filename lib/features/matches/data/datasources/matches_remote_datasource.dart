import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../domain/repositories/matches_repository.dart';
import '../models/match_model.dart';

abstract class MatchesRemoteDataSource {
  Future<List<MatchModel>> getMatchesByLeague(int leagueId, {DateTime? date});
  Future<List<MatchModel>> getMatchesByDate(DateTime date);
  Future<List<MatchModel>> getAllMatches();
  Future<List<MatchEventEntity>> getMatchEvents(String fixtureId);
  Future<List<MatchStatEntity>> getMatchStats(String fixtureId);
  Future<List<Map<String, dynamic>>> getLeagues();
  Future<List<Map<String, dynamic>>> getCountries();
}

class MatchesRemoteDataSourceImpl implements MatchesRemoteDataSource {
  final http.Client client;
  final String? apiKey;

  // For API-Sports (API-Football)
  static const String baseUrl = 'https://v3.football.api-sports.io';

  MatchesRemoteDataSourceImpl({required this.client, this.apiKey});

  Map<String, String> get _headers => {
        'x-apisports-key': apiKey ?? '',
        'x-rapidapi-host': 'v3.football.api-sports.io',
      };

  @override
  Future<List<MatchModel>> getMatchesByLeague(
    int leagueId, {
    DateTime? date,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _getMockMatches(leagueId: leagueId, date: date);
    }

    final dateStr = date != null ? DateFormat('yyyy-MM-dd').format(date) : null;
    final url = dateStr != null
        ? '$baseUrl/fixtures?league=$leagueId&date=$dateStr'
        : '$baseUrl/fixtures?league=$leagueId&next=10';

    final response = await client.get(Uri.parse(url), headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to load matches for league $leagueId');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List fixtures = data['response'] ?? [];
    return fixtures.map((f) => MatchModel.fromApiFootball(f)).toList();
  }

  @override
  Future<List<MatchModel>> getMatchesByDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    if (apiKey == null || apiKey!.isEmpty) {
      return _getMockMatches(date: date);
    }

    final response = await client.get(
      Uri.parse('$baseUrl/fixtures?date=$dateStr'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load matches for date $dateStr');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List fixtures = data['response'] ?? [];
    return fixtures.map((f) => MatchModel.fromApiFootball(f)).toList();
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
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load events');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List events = data['response'] ?? [];
    return events
        .map(
          (e) => MatchEventEntity(
            time: e['time']?['elapsed'] ?? 0,
            teamName: e['team']?['name'] ?? '',
            player: e['player']?['name'] ?? '',
            type: e['type'] ?? '',
            detail: e['detail'] ?? '',
          ),
        )
        .toList();
  }

  @override
  Future<List<MatchStatEntity>> getMatchStats(String fixtureId) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _getMockStats();
    }

    final response = await client.get(
      Uri.parse('$baseUrl/fixtures/statistics?fixture=$fixtureId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load statistics');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List responseData = data['response'] ?? [];
    if (responseData.length < 2) return [];

    final homeStats = responseData[0]['statistics'] as List;
    final awayStats = responseData[1]['statistics'] as List;

    final stats = <MatchStatEntity>[];
    for (var i = 0; i < homeStats.length; i++) {
      stats.add(
        MatchStatEntity(
          type: homeStats[i]['type'] ?? '',
          homeValue: homeStats[i]['value']?.toString() ?? '0',
          awayValue: awayStats[i]['value']?.toString() ?? '0',
        ),
      );
    }
    return stats;
  }

  @override
  Future<List<Map<String, dynamic>>> getLeagues() async {
    if (apiKey == null || apiKey!.isEmpty) return [];

    final response = await client.get(
      Uri.parse('$baseUrl/leagues'),
      headers: _headers,
    );

    if (response.statusCode != 200) return [];

    final Map<String, dynamic> data = json.decode(response.body);
    final List leagues = data['response'] ?? [];
    return leagues
        .map(
          (l) => {
            'id': l['league']?['id'],
            'name': l['league']?['name'],
            'country': l['country']?['name'],
          },
        )
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getCountries() async {
    if (apiKey == null || apiKey!.isEmpty) return [];

    final response = await client.get(
      Uri.parse('$baseUrl/countries'),
      headers: _headers,
    );

    if (response.statusCode != 200) return [];

    final Map<String, dynamic> data = json.decode(response.body);
    final List countries = data['response'] ?? [];
    return countries
        .map(
          (c) => {
            'name': c['name'],
            'code': c['code'],
            'flag': c['flag'],
          },
        )
        .toList();
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
    final resolvedLeagueId = leagueId ?? 233;
    final leagueName = leagueNames[resolvedLeagueId] ?? 'دوري غير معروف';

    return [
      MatchModel(
        id: '${resolvedLeagueId}_1_${now.day}',
        homeTeam: 'الأهلي',
        awayTeam: 'الزمالك',
        homeTeamLogo:
            'https://upload.wikimedia.org/wikipedia/en/a/a7/Al_Ahly_SC_logo.svg',
        awayTeamLogo:
            'https://upload.wikimedia.org/wikipedia/en/d/d4/Zamalek_SC_logo.svg',
        utcDate: now.copyWith(hour: 20, minute: 0),
        status: 'NS',
        leagueName: leagueName,
        leagueId: resolvedLeagueId,
      ),
      MatchModel(
        id: '${resolvedLeagueId}_2_${now.day}',
        homeTeam: 'بيراميدز',
        awayTeam: 'المصري',
        homeTeamLogo:
            'https://upload.wikimedia.org/wikipedia/en/c/c9/Pyramids_FC_logo.svg',
        awayTeamLogo:
            'https://upload.wikimedia.org/wikipedia/en/b/b3/Al-Masry_SC_logo.svg',
        utcDate: now.copyWith(hour: 18, minute: 30),
        status: 'NS',
        leagueName: leagueName,
        leagueId: resolvedLeagueId,
      ),
    ];
  }

  List<MatchEventEntity> _getMockEvents() {
    return const [
      MatchEventEntity(
        time: 12,
        teamName: 'الأهلي',
        player: 'محمد شريف',
        type: 'Goal',
        detail: 'Normal Goal',
      ),
      MatchEventEntity(
        time: 45,
        teamName: 'الزمالك',
        player: 'أحمد سيد زيزو',
        type: 'Card',
        detail: 'Yellow Card',
      ),
    ];
  }

  List<MatchStatEntity> _getMockStats() {
    return const [
      MatchStatEntity(type: 'الاستحواذ', homeValue: '55%', awayValue: '45%'),
      MatchStatEntity(type: 'التسديدات', homeValue: '12', awayValue: '8'),
      MatchStatEntity(
        type: 'التسديدات على المرمى',
        homeValue: '5',
        awayValue: '3',
      ),
    ];
  }
}
