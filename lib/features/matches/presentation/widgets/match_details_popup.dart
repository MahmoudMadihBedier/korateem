import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/matches_repository.dart';
import '../../domain/entities/match_entity.dart';
import 'package:korateem/ui/modern_components.dart';

class MatchDetailsPopup extends StatelessWidget {
  final MatchEntity match;

  const MatchDetailsPopup({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<IMatchesRepository>(context, listen: false);

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: DefaultTabController(
        length: 2,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                'تفاصيل المباراة',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Score Board
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTeam(match.homeTeam, match.homeTeamLogo, context),
                  Column(
                    children: [
                      Text(
                        match.score ?? 'VS',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.status == 'NS'
                            ? 'لم تبدأ'
                            : (match.status == 'FT' ? 'انتهت' : 'مباشر'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  _buildTeam(match.awayTeam, match.awayTeamLogo, context),
                ],
              ),

              const SizedBox(height: 24),

              // Tabs
              const TabBar(
                tabs: [
                  Tab(text: 'الأحداث'),
                  Tab(text: 'الإحصائيات'),
                ],
                indicatorColor: Color(0xFF43A047),
                labelColor: Color(0xFF43A047),
                unselectedLabelColor: Colors.grey,
              ),

              const SizedBox(height: 16),

              // Tab Content
              SizedBox(
                height: 300,
                child: TabBarView(
                  children: [
                    _EventsList(repository: repository, matchId: match.id),
                    _StatsList(repository: repository, matchId: match.id),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeam(String name, String logo, BuildContext context) {
    final isSvg = logo.toLowerCase().endsWith('.svg');

    return Column(
      children: [
        if (logo.isNotEmpty)
          SizedBox(
            width: 56,
            height: 56,
            child: isSvg
                ? SvgPicture.network(
                    logo,
                    fit: BoxFit.contain,
                    placeholderBuilder: (c) => const Icon(
                      Icons.sports_soccer,
                      size: 56,
                      color: Colors.grey,
                    ),
                  )
                : Image.network(
                    logo,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.sports_soccer,
                      size: 56,
                      color: Colors.grey,
                    ),
                  ),
          )
        else
          const Icon(Icons.sports_soccer, size: 56, color: Colors.grey),
        const SizedBox(height: 8),
        SizedBox(
          width: 90,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EventsList extends StatelessWidget {
  final IMatchesRepository repository;
  final String matchId;

  const _EventsList({required this.repository, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MatchEventEntity>>(
      future: repository.getMatchEvents(matchId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Text(
              'خطأ في تحميل الأحداث',
              style: TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد أحداث حالياً',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final events = snapshot.data!;
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${event.time}\'',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF43A047),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${event.player} (${event.teamName})',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _getEventDetailText(event.type, event.detail),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildEventIcon(event.type),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventIcon(String type) {
    switch (type.toLowerCase()) {
      case 'goal':
        return const Icon(Icons.sports_soccer, color: Colors.green, size: 20);
      case 'card':
        return const Icon(Icons.style, color: Colors.yellow, size: 20);
      case 'subst':
        return const Icon(Icons.swap_vert, color: Colors.blue, size: 20);
      default:
        return const Icon(Icons.info_outline, size: 20);
    }
  }

  String _getEventDetailText(String type, String detail) {
    if (type.toLowerCase() == 'goal') return 'هدف ($detail)';
    if (type.toLowerCase() == 'card') return 'بطاقة ($detail)';
    if (type.toLowerCase() == 'subst') return 'تبديل';
    return detail;
  }
}

class _StatsList extends StatelessWidget {
  final IMatchesRepository repository;
  final String matchId;

  const _StatsList({required this.repository, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MatchStatEntity>>(
      future: repository.getMatchStats(matchId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Text(
              'خطأ في تحميل الإحصائيات',
              style: TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'الإحصائيات غير متوفرة حالياً',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final stats = snapshot.data!;
        return ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stat.homeValue,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        stat.type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        stat.awayValue,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildStatBar(stat.homeValue, stat.awayValue),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatBar(String homeVal, String awayVal) {
    double h = double.tryParse(homeVal.replaceAll('%', '')) ?? 0;
    double a = double.tryParse(awayVal.replaceAll('%', '')) ?? 0;
    double total = h + a;
    if (total == 0) total = 1;

    return Row(
      children: [
        Expanded(
          flex: h.toInt(),
          child: Container(
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF43A047),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(2)),
            ),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          flex: a.toInt(),
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
