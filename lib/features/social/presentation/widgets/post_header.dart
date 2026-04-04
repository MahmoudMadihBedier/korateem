import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:korateem/features/social/domain/entities/post_entity.dart';
import 'package:korateem/features/social/presentation/controllers/social_feed_controller.dart';

class PostHeader extends StatelessWidget {
  final PostEntity post;
  final String timeLabel;

  const PostHeader({super.key, required this.post, required this.timeLabel});

  @override
  Widget build(BuildContext context) {
    final cachedName = (post.userName ?? '').trim();
    final cachedImage = (post.userImage ?? '').trim();

    if (cachedName.isNotEmpty || cachedImage.isNotEmpty) {
      return _HeaderRow(
        name: cachedName.isEmpty ? 'مستخدم' : cachedName,
        imageUrl: cachedImage,
        timeLabel: timeLabel,
      );
    }

    final controller = context.read<SocialFeedController>();
    return FutureBuilder<UserPreview>(
      future: controller.resolveUser(post.userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.name ?? 'مستخدم';
        final imageUrl = user?.imageUrl ?? '';
        return _HeaderRow(name: name, imageUrl: imageUrl, timeLabel: timeLabel);
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String timeLabel;

  const _HeaderRow({
    required this.name,
    required this.imageUrl,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
          child: hasImage
              ? null
              : const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleMedium),
              Text(timeLabel, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

