import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:korateem/services/auth_service.dart';
import 'package:korateem/services/user_role_service.dart';
import 'package:korateem/screens/stadium_bookings_review_page.dart';
import 'package:korateem/screens/stadium_photos_page.dart';
import 'package:korateem/screens/stadium_schedule_page.dart';
import 'package:korateem/screens/stadium_profile_page.dart';
import '../ui/modern_components.dart';
import '../../services/owner_service.dart';

class StadiumDashboardPage extends StatefulWidget {
  final String ownerId;

  const StadiumDashboardPage({super.key, required this.ownerId});

  @override
  State<StadiumDashboardPage> createState() => _StadiumDashboardPageState();
}

class _StadiumDashboardPageState extends State<StadiumDashboardPage> {
  late OwnerService _ownerService;

  @override
  void initState() {
    super.initState();
    _ownerService = OwnerService();
  }

  @override
  Widget build(BuildContext context) {
    final uid =
        Provider.of<AuthService>(context, listen: false).currentUser?.uid ?? '';
    final roleService = UserRoleService();
    if (uid.trim().isEmpty || uid != widget.ownerId) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: EmptyState(
          icon: Icons.lock_outline,
          title: 'غير مسموح',
          subtitle: 'هذه الصفحة متاحة لصاحب الملعب فقط',
        ),
      );
    }

    return StreamBuilder<String?>(
      stream: roleService.watchRole(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: ModernLoading());
        }
        final role = (snapshot.data ?? '').toLowerCase().trim();
        if (role != 'owner') {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: EmptyState(
              icon: Icons.lock_outline,
              title: 'غير مسموح',
              subtitle: 'حسابك لاعب. لا يمكنك إدارة الملاعب.',
            ),
          );
        }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: ModernAppBar(title: 'My Stadiums'),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: _ownerService.getOwnerStadiums(widget.ownerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: ModernLoading(),
              );
            }

            if (snapshot.hasError) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Error Loading Stadiums',
                subtitle: 'Failed to load your stadiums',
                actionLabel: 'Retry',
                onAction: () => setState(() {}),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: EmptyState(
                  icon: Icons.stadium_outlined,
                  title: 'No Stadiums Yet',
                  subtitle: 'Create your first stadium to get started',
                  actionLabel: 'Create Stadium',
                  onAction: () {
                    Navigator.pushNamed(
                      context,
                      '/stadium-profile',
                      arguments: {'ownerId': widget.ownerId},
                    );
                  },
                ),
              );
            }

            final stadiums = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stadiums.length,
              itemBuilder: (context, index) {
                final stadium = stadiums[index].data() as Map<String, dynamic>;
                final stadiumId = stadiums[index].id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stadium Header
                        Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF43A047),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.stadium,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stadium['name'] ?? 'Stadium',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Color(0xFF808080),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          stadium['address'] ?? 'No address',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Description
                        Text(
                          stadium['description'] ?? 'No description',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Contact Info
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 16,
                              color: Color(0xFF43A047),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              stadium['phone'] ?? 'No phone',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFF404040), height: 1),
                        const SizedBox(height: 12),
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.calendar_month,
                                label: 'الحجوزات',
                                color: const Color(0xFF43A047),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StadiumBookingsReviewPage(
                                      stadiumId: stadiumId,
                                      stadiumName: (stadium['name'] ?? 'ملعب')
                                          .toString(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.edit,
                                label: 'تعديل',
                                color: Colors.blue,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StadiumProfilePage(
                                      ownerId: widget.ownerId,
                                      stadiumId: stadiumId,
                                      initialData: stadium,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.photo_library_outlined,
                                label: 'الصور',
                                color: const Color(0xFF66BB6A),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StadiumPhotosPage(
                                      stadiumId: stadiumId,
                                      stadiumName: (stadium['name'] ?? 'ملعب')
                                          .toString(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.schedule,
                                label: 'Schedule',
                                color: const Color(0xFFFFA500),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        StadiumSchedulePage(stadiumId: stadiumId),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_stadium_dashboard',
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/stadium-profile',
            arguments: {'ownerId': widget.ownerId},
          );
        },
        backgroundColor: const Color(0xFF43A047),
        child: const Icon(Icons.add),
      ),
    );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF404040)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
