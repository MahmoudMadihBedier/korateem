import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:korateem/features/social/domain/entities/post_entity.dart';
import 'package:korateem/features/social/domain/repositories/post_repository.dart';
import 'package:korateem/features/social/presentation/controllers/social_feed_controller.dart';
import 'package:korateem/features/social/presentation/formatters/relative_time_formatter.dart';
import 'package:korateem/features/social/presentation/widgets/comments_sheet.dart';
import 'package:korateem/features/social/presentation/widgets/post_header.dart';
import 'package:korateem/features/user/data/repositories/user_repository.dart';
import 'package:korateem/ui/modern_components.dart';

class SocialFeedPage extends StatefulWidget {
  final String userId;

  const SocialFeedPage({super.key, required this.userId});

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage> {
  late final SocialFeedController _controller;
  final RelativeTimeFormatter _timeFormatter = const RelativeTimeFormatter();

  @override
  void initState() {
    super.initState();
    _controller = SocialFeedController(
      currentUserId: widget.userId,
      postRepository: context.read<IPostRepository>(),
      userRepository: context.read<IUserRepository>(),
    );
  }

  Future<void> _toggleLike(String postId) async {
    try {
      await _controller.toggleLike(postId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFCF6679),
        ),
      );
    }
  }

  void _showCreatePostDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Post',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'What is on your mind?',
                  hintStyle: const TextStyle(color: Color(0xFF808080)),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF404040)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF404040)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF43A047),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF808080)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;
                      try {
                        await _controller.createPost(content: text);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post created successfully!'),
                            backgroundColor: Color(0xFF43A047),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: const Color(0xFFCF6679),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      minimumSize: const Size(120, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Post', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCommentsSheet(String postId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Provider.value(
        value: _controller,
        child: CommentsSheet(postId: postId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: const ModernAppBar(title: 'Social Feed', glassy: true),
        body: StreamBuilder<List<PostEntity>>(
          stream: _controller.watchFeed(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ModernLoading();
            }

            if (snapshot.hasError) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Error Loading Posts',
                subtitle: 'An error occurred while loading posts',
                actionLabel: 'Retry',
                onAction: () => setState(() {}),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No Posts Yet',
                subtitle: 'Be the first to post!',
                actionLabel: 'Create Post',
                onAction: _showCreatePostDialog,
              );
            }

            final posts = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final timeLabel = _timeFormatter.formatEnglish(post.createdAt);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedListItem(
                    delay: Duration(milliseconds: 24 * (index.clamp(0, 12))),
                    child: ModernCard.glass(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PostHeader(post: post, timeLabel: timeLabel),
                        const SizedBox(height: 12),
                        Text(
                          post.content,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (post.imageUrl != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              post.imageUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: const Color(0xFF2A2A2A),
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Color(0xFF808080),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 18,
                              color: post.likes.contains(widget.userId)
                                  ? Colors.red
                                  : const Color(0xFF808080),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.likes.length}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.comment_outlined,
                              size: 18,
                              color: Color(0xFF43A047),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.commentsCount}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFF404040), height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: post.likes.contains(widget.userId)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                label: 'Like',
                                color: post.likes.contains(widget.userId)
                                    ? Colors.red
                                    : const Color(0xFF808080),
                                onTap: () => _toggleLike(post.id),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.comment_outlined,
                                label: 'Comment',
                                color: const Color(0xFF43A047),
                                onTap: () => _openCommentsSheet(post.id),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.share_outlined,
                                label: 'Share',
                                color: const Color(0xFF66BB6A),
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'fab_social_feed',
          onPressed: _showCreatePostDialog,
          backgroundColor: const Color(0xFF43A047),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
