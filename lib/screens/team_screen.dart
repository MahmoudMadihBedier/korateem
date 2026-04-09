import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/team_service.dart';
import '../models/team_model.dart';
import 'create_team_page.dart';
import '../features/user/data/repositories/user_repository.dart';
import '../features/user/data/models/user_model.dart';
import 'package:korateem/services/user_role_service.dart';
import 'package:korateem/ui/modern_components.dart';

class TeamScreen extends StatelessWidget {
  final String currentUserId;

  const TeamScreen({super.key, required this.currentUserId});

  Widget _teamImage(TeamModel team, {required double width, required double height}) {
    final url = team.imageUrl.trim();
    if (url.isNotEmpty) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/studim.jpeg',
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        },
      );
    }

    final data = team.imageData.trim();
    if (data.isNotEmpty) {
      try {
        final bytes = base64Decode(data);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/studim.jpeg',
              width: width,
              height: height,
              fit: BoxFit.cover,
            );
          },
        );
      } catch (_) {
        // Fall through to placeholder.
      }
    }

    return Image.asset(
      'assets/images/studim.jpeg',
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  void _showTeamDetails(BuildContext context, TeamModel team) {
    final userRepository = UserRepository();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF404040),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _teamImage(
                        team,
                        width: double.infinity,
                        height: 180,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            team.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFFA500)),
                            const SizedBox(width: 4),
                            Text(
                              team.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'الكابتن: ${team.captainName.isNotEmpty ? team.captainName : team.captainId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatChip(
                          label: 'المباريات',
                          value: '${team.totalMatches}',
                        ),
                        _StatChip(label: 'فوز', value: '${team.wins}'),
                        _StatChip(label: 'تعادل', value: '${team.draws}'),
                        _StatChip(label: 'خسارة', value: '${team.losses}'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'الأعضاء (5)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<UserModel>>(
                      future: userRepository.getUsersByIds(team.memberIds),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final members = snapshot.data!;
                        // Preserve ordering by memberIds if possible.
                        final byId = {for (final u in members) u.id: u};
                        final ordered = team.memberIds
                            .map((id) => byId[id])
                            .whereType<UserModel>()
                            .toList();

                        if (ordered.isEmpty) {
                          return Text(
                            team.memberIds.join('\n'),
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        }

                        return Column(
                          children: ordered.map((u) {
                            final isCaptain = u.id == team.captainId;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF43A047),
                                backgroundImage:
                                    (u.profileImage != null &&
                                        u.profileImage!.trim().isNotEmpty)
                                    ? NetworkImage(u.profileImage!)
                                    : null,
                                child:
                                    (u.profileImage == null ||
                                        u.profileImage!.trim().isEmpty)
                                    ? Text(
                                        u.name.isNotEmpty ? u.name[0] : 'U',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                u.name.isNotEmpty ? u.name : 'مستخدم',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                u.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              trailing: isCaptain
                                  ? const Icon(
                                      Icons.star,
                                      color: Color(0xFFFFA500),
                                    )
                                  : null,
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final teamService = TeamService();
    if (currentUserId.trim().isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('الفرق')),
        body: const Center(child: Text('سجل الدخول علشان تنشئ وتعرض فرقك')),
      );
    }
    final roleService = UserRoleService();
    return StreamBuilder<String?>(
      stream: roleService.watchRole(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: ModernLoading());
        }
        final role = (snapshot.data ?? '').toLowerCase().trim();
        if (role == 'owner') {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: EmptyState(
              icon: Icons.lock_outline,
              title: 'غير متاح',
              subtitle: 'حساب صاحب الملعب لا يملك صلاحيات اللاعب/الفرق',
            ),
          );
        }
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: ModernAppBar(
        title: 'الفرق',
        showNotification: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ModernCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateTeamPage(currentUserId: currentUserId),
                ),
              ),
              backgroundColor: const Color(0xFF43A047).withValues(alpha: 0.1),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'إنشاء فريق جديد',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'كون فريقك الخاص والعب مع أصدقائك',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: teamService.getTeamsForUser(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('حدث خطأ أثناء تحميل الفرق'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var teams = snapshot.data!.docs;
                if (teams.isEmpty) {
                  return const EmptyState(
                    icon: Icons.group_off_outlined,
                    title: 'لا توجد فرق',
                    subtitle: 'ابدأ بإنشاء فريقك الأول الآن',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final model = TeamModel.fromFirestore(teams[index]);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ModernCard.glass(
                        onTap: () => _showTeamDetails(context, model),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey),
                            const Spacer(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    model.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'عدد الأعضاء: ${model.memberIds.length}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _teamImage(model, width: 60, height: 60),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
