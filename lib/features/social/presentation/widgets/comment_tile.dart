import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:korateem/features/social/domain/entities/post_entity.dart';
import 'package:korateem/features/social/presentation/controllers/social_feed_controller.dart';
import 'package:korateem/ui/modern_components.dart';

class CommentTile extends StatelessWidget {
  final CommentEntity comment;

  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final cachedName = (comment.userName ?? '').trim();
    final cachedImage = (comment.userImage ?? '').trim();

    if (cachedName.isNotEmpty || cachedImage.isNotEmpty) {
      return _CommentBody(
        name: cachedName.isEmpty ? 'مستخدم' : cachedName,
        imageUrl: cachedImage,
        text: comment.text,
      );
    }

    final controller = context.read<SocialFeedController>();
    return FutureBuilder<UserPreview>(
      future: controller.resolveUser(comment.userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return _CommentBody(
          name: user?.name ?? 'مستخدم',
          imageUrl: user?.imageUrl ?? '',
          text: comment.text,
        );
      },
    );
  }
}

class _CommentBody extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String text;

  const _CommentBody({
    required this.name,
    required this.imageUrl,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;
    return ModernCard.glass(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
            child: hasImage
                ? null
                : const Icon(Icons.person, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
