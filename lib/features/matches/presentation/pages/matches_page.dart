import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:korateem/ui/modern_components.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/matches_repository.dart';
import '../widgets/match_card_widget.dart';
import '../widgets/match_filter_bottom_sheet.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage>
    with SingleTickerProviderStateMixin {
  late TabController _dateTabController;
  final List<({DateTime date, String label})> _dates = [
    (date: DateTime.now().subtract(const Duration(days: 1)), label: 'أمس'),
    (date: DateTime.now(), label: 'اليوم'),
    (date: DateTime.now().add(const Duration(days: 1)), label: 'غداً'),
  ];

  int? _selectedLeagueId;
  String? _selectedStatus;
  String? _selectedCountry;

  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _leagues = [];

  @override
  void initState() {
    super.initState();
    _dateTabController =
        TabController(length: _dates.length, vsync: this, initialIndex: 1);
    _loadFilterOptions();
  }

  Future<void> _loadFilterOptions() async {
    final repository = Provider.of<IMatchesRepository>(context, listen: false);
    final countries = await repository.getCountries();
    final leagues = await repository.getLeagues();
    if (!mounted) return;
    setState(() {
      _countries = countries;
      _leagues = leagues;
    });
  }

  @override
  void dispose() {
    _dateTabController.dispose();
    super.dispose();
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MatchFilterBottomSheet(
        countries: _countries,
        leagues: _leagues,
        onApply: (country, league, status) {
          setState(() {
            _selectedCountry = country;
            _selectedLeagueId = league;
            _selectedStatus = status;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<IMatchesRepository>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: const ModernAppBar(
        title: 'جدول المباريات',
        showNotification: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilter,
        child: const Icon(Icons.filter_list),
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
                  leagueId: _selectedLeagueId,
                  status: _selectedStatus,
                  country: _selectedCountry,
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
        indicatorPadding: EdgeInsets.zero,
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
  final int? leagueId;
  final String? status;
  final String? country;

  const _MatchesList({
    required this.repository,
    required this.date,
    this.leagueId,
    this.status,
    this.country,
  });

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
    if (oldWidget.date != widget.date ||
        oldWidget.leagueId != widget.leagueId ||
        oldWidget.status != widget.status ||
        oldWidget.country != widget.country) {
      _loadMatches();
    }
  }

  void _loadMatches() {
    if (widget.leagueId != null) {
      _matchesFuture = widget.repository.getMatchesByLeague(
        widget.leagueId!,
        date: widget.date,
      );
    } else {
      _matchesFuture = widget.repository.getMatchesByDate(widget.date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MatchEntity>>(
      future: _matchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ModernLoading(message: 'جاري تحميل المباريات...');
        }
        if (snapshot.hasError) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'خطأ في تحميل البيانات',
            subtitle: 'تأكد من اتصالك بالإنترنت',
            onAction: () {
              setState(_loadMatches);
            },
            actionLabel: 'إعادة المحاولة',
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyState(
            icon: Icons.sports_soccer,
            title: 'لا توجد مباريات حالياً',
            subtitle: 'انتظر بدء المنافسات قريباً',
          );
        }

        final matches = snapshot.data!;
        var filteredMatches = matches;

        if (widget.status != null) {
          filteredMatches = filteredMatches
              .where((m) => m.status.contains(widget.status!))
              .toList();
        }

        if (widget.country != null && widget.leagueId == null) {
          final countryLower = widget.country!.toLowerCase();
          filteredMatches = filteredMatches
              .where((m) => m.leagueName.toLowerCase().contains(countryLower))
              .toList();
        }

        if (filteredMatches.isEmpty) {
          return const EmptyState(
            icon: Icons.sports_soccer,
            title: 'لا توجد مباريات تطابق التصفية',
            subtitle: 'جرب تغيير خيارات التصفية',
          );
        }

        final groupedMatches = <String, List<MatchEntity>>{};
        for (final match in filteredMatches) {
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(
                    leagueName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.right,
                  ),
                ),
                ...leagueMatches
                    .map(
                      (match) => AnimatedListItem(
                        delay: const Duration(milliseconds: 50),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: MatchCardWidget(match: match),
                        ),
                      ),
                    ),
              ],
            );
          },
        );
      },
    );
  }
}
