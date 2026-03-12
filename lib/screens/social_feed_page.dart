import 'package:flutter/material.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        backgroundColor: Colors.green[700],
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: _postRepository.getAllPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No posts yet. Be the first to post!'),
            );
          }

          final posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: post.imageUrl != null
                                ? NetworkImage(post.imageUrl!)
                                : null,
                            child: post.imageUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'User ${post.userId.substring(0, 8)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatTime(post.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Post Content
                      Text(post.content),
                      if (post.imageUrl != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Engagement Stats
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 16,
                            color: Colors.red,
                          ),
                          Text(' ${post.likes.length}'),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.comment,
                            size: 16,
                            color: Colors.blue,
                          ),
                          Text(' ${post.comments.length}'),
                        ],
                      ),
                      const Divider(),
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _likePost(post.id, post.likes),
                            icon: Icon(
                              post.likes.contains(widget.userId)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: post.likes.contains(widget.userId)
                                  ? Colors.red
                                  : null,
                            ),
                            label: const Text('Like'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showCommentDialog(context, post.id),
                            icon: const Icon(Icons.comment),
                            label: const Text('Comment'),
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
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'What\'s on your mind?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Post created!')));
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(BuildContext context, String postId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Write your comment...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final comment = CommentModel(
                  userId: widget.userId,
                  text: controller.text,
                  createdAt: DateTime.now(),
                );
                await _postRepository.addComment(postId, comment);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Comment added!')));
              }
            },
            child: const Text('Comment'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
