import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/match_entity.dart';
import 'package:korateem/ui/modern_components.dart';
import 'match_details_popup.dart';

class MatchCardWidget extends StatelessWidget {
  final MatchEntity match;

  const MatchCardWidget({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm');
    final dateStr = dateFormat.format(match.utcDate.toLocal());

    return ModernCard.glass(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => MatchDetailsPopup(match: match),
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                match.leagueName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
              Text(
                _getStatusText(match.status),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Home Team
              Expanded(
                child: Column(
                  children: [
                    _buildLogo(match.homeTeamLogo),
                    const SizedBox(height: 8),
                    Text(
                      match.homeTeam,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Score / Time
              SizedBox(
                width: 100,
                child: Column(
                  children: [
                    if (match.score != null)
                      Text(
                        match.score!,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      )
                    else
                      Text(
                        dateStr,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (match.status == 'IN_PLAY' || match.status == 'LIVE')
                      const Text(
                        'مباشر',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                      )
                    else if (match.score != null)
                      const Text(
                        'انتهت',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                  ],
                ),
              ),

              // Away Team
              Expanded(
                child: Column(
                  children: [
                    _buildLogo(match.awayTeamLogo),
                    const SizedBox(height: 8),
                    Text(
                      match.awayTeam,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(String url) {
    if (url.isEmpty) {
      return const CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white12,
        child: Icon(Icons.sports_soccer, color: Colors.white24),
      );
    }

    final isSvg = url.toLowerCase().endsWith('.svg');

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: isSvg
            ? SvgPicture.network(
                url,
                fit: BoxFit.contain,
                placeholderBuilder: (context) => const Icon(Icons.sports_soccer, color: Colors.grey),
              )
            : Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.sports_soccer, color: Colors.grey),
              ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'NS':
      case 'SCHEDULED':
        return 'لم تبدأ';
      case 'LIVE':
      case 'IN_PLAY':
        return 'جارية الآن';
      case 'FT':
      case 'FINISHED':
        return 'انتهت';
      case 'PST':
      case 'POSTPONED':
        return 'مؤجلة';
      default:
        return status;
    }
  }
}
