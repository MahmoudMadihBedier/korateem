import 'package:flutter/material.dart';
import '../ui/modern_components.dart';
import '../../features/social/data/models/post_model.dart';
import '../../features/social/data/repositories/post_repository.dart';

class SocialFeedPage extends StatefulWidget {
  final String userId;

  const SocialFeedPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage> {
  late PostRepository _postRepository;

  @override
  void initState() {
    super.initState();
    _postRepository = PostRepository();
  }

  Future<void> _likePost(String postId, List<String> currentLikes) async {
    try {
      if (currentLikes.contains(widget.userId)) {
        currentLikes.remove(widget.userId);
      } else {
        currentLikes.add(widget.userId);
      }
      await _postRepository.likePost(postId, widget.userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFCF6679),
          ),
        );
      }
    }
  }

  void _showCreatePostDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
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
                      if (controller.text.isNotEmpty) {
                        final post = PostModel(
                          id: '',
                          userId: widget.userId,
                          content: controller.text,
                          createdAt: DateTime.now(),
                        );
                        await _postRepository.createPost(post);
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Post created successfully!'),
                              backgroundColor: Color(0xFF43A047),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Post',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommentDialog(BuildContext context, String postId) {
    final controller = TextEditingController();
    showDialog(
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
                'Add Comment',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Write your comment...',
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
                      if (controller.text.isNotEmpty) {
                        final comment = CommentModel(
                          userId: widget.userId,
                          text: controller.text,
                          createdAt: DateTime.now(),
                        );
                        await _postRepository.addComment(postId, comment);
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Comment added!'),
                              backgroundColor: Color(0xFF43A047),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: ModernAppBar(title: 'Social Feed'),
      body: StreamBuilder<List<PostModel>>(
        stream: _postRepository.getAllPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ModernLoading();
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
              onAction: () => _showCreatePostDialog(context),
            );
          }

          final posts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF43A047),
                            backgroundImage: post.imageUrl != null
                                ? NetworkImage(post.imageUrl!)
                                : null,
                            child: post.imageUrl == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'User ${post.userId.substring(0, 8)}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Text(
                                  _formatTime(post.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Post Content
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
                      // Engagement Stats
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
                            '${post.comments.length}',
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
                              icon: post.likes.contains(widget.userId)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              label: 'Like',
                              color: post.likes.contains(widget.userId)
                                  ? Colors.red
                                  : const Color(0xFF808080),
                              onTap: () => _likePost(post.id, post.likes),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.comment_outlined,
                              label: 'Comment',
                              color: const Color(0xFF43A047),
                              onTap: () => _showCommentDialog(context, post.id),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        backgroundColor: const Color(0xFF43A047),
        child: const Icon(Icons.add),
      ),
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
