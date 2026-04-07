import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:korateem/features/social/presentation/controllers/social_feed_controller.dart';
import 'package:korateem/ui/modern_components.dart';

class CreatePostCard extends StatelessWidget {
  final VoidCallback onCreate;

  const CreatePostCard({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final social = context.read<SocialFeedController>();
    return FutureBuilder<UserPreview>(
      future: social.resolveUser(social.currentUserId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.name.trim().isNotEmpty == true ? user!.name : 'أنت';
        final imageUrl = (user?.imageUrl ?? '').trim();
        final hasImage = imageUrl.isNotEmpty;

        return ModernCard.glass(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
                      child: hasImage
                          ? null
                          : Text(
                              name.isNotEmpty ? name[0] : 'أ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: onCreate,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Text(
                            'بماذا تفكر؟',
                            textAlign: TextAlign.right,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.78,
                                      ),
                                      fontSize: 16,
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.16),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.photo_outlined,
                        label: 'صورة',
                        onTap: onCreate,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 22,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.videocam_outlined,
                        label: 'فيديو',
                        onTap: onCreate,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 22,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.place_outlined,
                        label: 'موقع',
                        onTap: onCreate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withValues(alpha: 0.78);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontSize: 13,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
