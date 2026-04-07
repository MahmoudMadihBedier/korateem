import 'package:flutter/material.dart';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تفاصيل المباراة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeam(match.homeTeam, match.homeTeamLogo, context),
                Text(
                  match.score ?? 'VS',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                _buildTeam(match.awayTeam, match.awayTeamLogo, context),
              ],
            ),
            const Divider(height: 40, color: Colors.white24),
            Text(
              'أحداث المباراة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<MatchEventEntity>>(
                future: repository.getMatchEvents(match.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('خطأ في تحميل الأحداث', style: TextStyle(color: Colors.red)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('لا توجد أحداث حالياً', style: TextStyle(color: Colors.grey)));
                  }

                  final events = snapshot.data!;
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${event.time}\'', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeam(String name, String logo, BuildContext context) {
    return Column(
      children: [
        if (logo.isNotEmpty)
          Image.network(logo, width: 48, height: 48, errorBuilder: (c, e, s) => const Icon(Icons.sports_soccer))
        else
          const Icon(Icons.sports_soccer, size: 48),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
