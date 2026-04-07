import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  late TabController _tabController;
  final List<({int id, String name})> _leagues = [
    (id: 0, name: 'الكل'),
    (id: 233, name: 'الدوري المصري'),
    (id: 140, name: 'الدوري الإسباني'),
    (id: 39, name: 'الدوري الإنجليزي'),
    (id: 2, name: 'دوري الأبطال (أوروبا)'),
    (id: 12, name: 'دوري الأبطال (أفريقيا)'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _leagues.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          _buildLeagueSelector(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _leagues.map((league) {
                return _MatchesList(
                  repository: repository,
                  leagueId: league.id,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueSelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey,
        tabs: _leagues.map((league) {
          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                league.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MatchesList extends StatefulWidget {
  final IMatchesRepository repository;
  final int leagueId;

  const _MatchesList({required this.repository, required this.leagueId});

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
    if (oldWidget.leagueId != widget.leagueId) {
      _loadMatches();
    }
  }

  void _loadMatches() {
    _matchesFuture = (widget.leagueId == 0)
        ? widget.repository.getAllMatches()
        : widget.repository.getMatchesByLeague(widget.leagueId);
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

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            return AnimatedListItem(
              delay: Duration(milliseconds: index * 50),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MatchCardWidget(match: matches[index]),
              ),
            );
          },
        );
      },
    );
  }
}
