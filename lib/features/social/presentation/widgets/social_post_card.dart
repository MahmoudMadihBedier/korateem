import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:korateem/features/social/domain/entities/post_entity.dart';
import 'package:korateem/features/social/presentation/controllers/social_feed_controller.dart';
import 'package:korateem/features/social/presentation/widgets/post_header.dart';
import 'package:korateem/features/social/presentation/widgets/post_details_dialog.dart';
import 'package:korateem/ui/modern_components.dart';

class SocialPostCard extends StatefulWidget {
  final PostEntity post;
  final String currentUserId;
  final String timeLabel;

  const SocialPostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.timeLabel,
  });

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard> {
  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final liked = post.likes.contains(widget.currentUserId);
    final comments = post.comments.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final preview =
        comments.length <= 2 ? comments : comments.sublist(comments.length - 2);

    Future<void> openDetails({bool autofocusComment = false}) {
      HapticFeedback.selectionClick();
      return showPostDetailsDialog(
        context,
        controller: context.read<SocialFeedController>(),
        postId: post.id,
        autofocusComment: autofocusComment,
      );
    }

    return ModernCard.glass(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => openDetails(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PostHeader(post: post, timeLabel: widget.timeLabel),
                  const SizedBox(height: 12),
                  Text(
                    post.content,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                  ),
                  if (post.imageUrl != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        post.imageUrl!,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 220,
                            color: const Color(0xFF2A2A2A),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Color(0xFF808080),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _StatsRow(
            likes: post.likes.length,
            comments: post.commentsCount,
          ),
          _ActionsRow(
            liked: liked,
            onLike: () async {
              HapticFeedback.selectionClick();
              await context.read<SocialFeedController>().toggleLike(post.id);
            },
            onComment: () => openDetails(autofocusComment: true),
            onShare: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ميزة المشاركة قريباً.')),
              );
            },
          ),
          if (preview.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final c in preview) ...[
                    _InlineCommentBubble(comment: c),
                    const SizedBox(height: 8),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => openDetails(),
                      child: Text(
                        post.commentsCount > 2
                            ? 'عرض كل التعليقات (${post.commentsCount})'
                            : 'عرض التعليقات',
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int likes;
  final int comments;

  const _StatsRow({required this.likes, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            Icons.favorite,
            size: 16,
            color: Colors.red.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 6),
          Text(
            '$likes',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 14),
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 16,
            color: Color(0xFF43A047),
          ),
          const SizedBox(width: 6),
          Text(
            '$comments',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const _ActionsRow({
    required this.liked,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ActionChip(
              icon: liked ? Icons.favorite : Icons.favorite_border_rounded,
              label: 'إعجاب',
              color: liked ? Colors.red : const Color(0xFFB0B0B0),
              onTap: onLike,
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          Expanded(
            child: _ActionChip(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'تعليق',
              color: const Color(0xFF43A047),
              onTap: onComment,
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          Expanded(
            child: _ActionChip(
              icon: Icons.share_outlined,
              label: 'مشاركة',
              color: const Color(0xFF66BB6A),
              onTap: onShare,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                child: child,
              ),
              child: Icon(
                icon,
                key: ValueKey(icon.codePoint),
                size: 20,
                color: color,
              ),
            ),
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

class _InlineCommentBubble extends StatelessWidget {
  final CommentEntity comment;

  const _InlineCommentBubble({required this.comment});

  @override
  Widget build(BuildContext context) {
    final cachedName = (comment.userName ?? '').trim();
    final cachedImage = (comment.userImage ?? '').trim();
    final hasCached = cachedName.isNotEmpty || cachedImage.isNotEmpty;

    if (hasCached) {
      return _InlineCommentBubbleBody(
        name: cachedName.isEmpty ? 'مستخدم' : cachedName,
        imageUrl: cachedImage,
        text: comment.text,
      );
    }

    return FutureBuilder<UserPreview>(
      future: context.read<SocialFeedController>().resolveUser(comment.userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return _InlineCommentBubbleBody(
          name: (user?.name ?? 'مستخدم').trim(),
          imageUrl: (user?.imageUrl ?? '').trim(),
          text: comment.text,
        );
      },
    );
  }
}

class _InlineCommentBubbleBody extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String text;

  const _InlineCommentBubbleBody({
    required this.name,
    required this.imageUrl,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
            child: hasImage
                ? null
                : Text(
                    name.isNotEmpty ? name[0] : 'م',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  name.isEmpty ? 'مستخدم' : name,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
