import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/repositories/matches_repository.dart';
import '../../domain/entities/match_entity.dart';
import '../widgets/match_card_widget.dart';
import 'package:korateem/ui/modern_components.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> with SingleTickerProviderStateMixin {
  late TabController _dateTabController;
  final List<({DateTime date, String label})> _dates = [
    (date: DateTime.now().subtract(const Duration(days: 1)), label: 'أمس'),
    (date: DateTime.now(), label: 'اليوم'),
    (date: DateTime.now().add(const Duration(days: 1)), label: 'غداً'),
  ];

  @override
  void initState() {
    super.initState();
    _dateTabController = TabController(length: _dates.length, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _dateTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<IMatchesRepository>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: ModernAppBar(
        title: 'جدول المباريات',
        showNotification: false,
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: TabBarView(
              controller: _dateTabController,
              children: _dates.map((dateItem) {
                return _MatchesList(
                  repository: repository,
                  date: dateItem.date,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TabBar(
        controller: _dateTabController,
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey,
        tabs: _dates.map((dateItem) {
          return Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dateItem.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('MM/dd').format(dateItem.date),
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MatchesList extends StatefulWidget {
  final IMatchesRepository repository;
  final DateTime date;

  const _MatchesList({required this.repository, required this.date});

  @override
  State<_MatchesList> createState() => _MatchesListState();
}

class _MatchesListState extends State<_MatchesList> {
  late Future<List<MatchEntity>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  @override
  void didUpdateWidget(covariant _MatchesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      _loadMatches();
    }
  }

  void _loadMatches() {
    _matchesFuture = widget.repository.getMatchesByDate(widget.date);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MatchEntity>>(
      future: _matchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ModernLoading(message: 'جاري تحميل المباريات...');
        } else if (snapshot.hasError) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'خطأ في تحميل البيانات',
            subtitle: 'تأكد من اتصالك بالإنترنت',
            onAction: () {
              setState(() {
                _loadMatches();
              });
            },
            actionLabel: 'إعادة المحاولة',
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyState(
            icon: Icons.sports_soccer,
            title: 'لا توجد مباريات حالياً',
            subtitle: 'انتظر بدء المنافسات قريباً',
          );
        }

        final matches = snapshot.data!;
        // Group by league
        Map<String, List<MatchEntity>> groupedMatches = {};
        for (var match in matches) {
          (groupedMatches[match.leagueName] ??= []).add(match);
        }

        final leagueNames = groupedMatches.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: leagueNames.length,
          itemBuilder: (context, leagueIndex) {
            final leagueName = leagueNames[leagueIndex];
            final leagueMatches = groupedMatches[leagueName]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(
                    leagueName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                ...leagueMatches.map((match) => AnimatedListItem(
                  delay: const Duration(milliseconds: 50),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MatchCardWidget(match: match),
                  ),
                )).toList(),
              ],
            );
          },
        );
      },
    );
  }
}
