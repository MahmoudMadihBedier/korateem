import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korateem/features/matches/domain/entities/match_entity.dart';
import 'package:korateem/features/matches/domain/repositories/matches_repository.dart';
import 'package:korateem/features/matches/presentation/pages/matches_page.dart';
import 'package:korateem/features/matches/presentation/widgets/match_card_widget.dart';
import 'package:provider/provider.dart';

class MockMatchesRepository implements IMatchesRepository {
  @override
  Future<List<MatchEntity>> getAllMatches() async {
    return [
      MatchEntity(
        id: '1',
        homeTeam: 'Team A',
        awayTeam: 'Team B',
        homeTeamLogo: '',
        awayTeamLogo: '',
        utcDate: DateTime.now().add(const Duration(hours: 1)),
        status: 'NS',
        leagueName: 'Test League',
      ),
    ];
  }

  @override
  Future<List<MatchEntity>> getMatchesByLeague(int leagueId) async {
    return [];
  }
}

void main() {
  testWidgets('MatchesPage builds and displays matches', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<IMatchesRepository>(create: (_) => MockMatchesRepository()),
        ],
        child: const MaterialApp(
          home: MatchesPage(),
        ),
      ),
    );

    expect(find.text('جدول المباريات'), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(MatchCardWidget), findsOneWidget);
    expect(find.text('Team A'), findsOneWidget);
    expect(find.text('Team B'), findsOneWidget);
  });
}
