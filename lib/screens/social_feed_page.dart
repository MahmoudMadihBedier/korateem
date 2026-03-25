import 'package:flutter/material.dart';
import 'package:korateem/services/user_service.dart';
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
  final UserService _userService = UserService();
  final Map<String, Future<_UserPreview>> _userCache = {};

  @override
  void initState() {
    super.initState();
    _postRepository = PostRepository();
  }

  Future<_UserPreview> _getUserPreview(String uid) {
    if (uid.trim().isEmpty) {
      return Future.value(const _UserPreview(name: 'مستخدم', imageUrl: ''));
    }
    return _userCache.putIfAbsent(uid, () async {
      final doc = await _userService.getUserProfile(uid);
      final data = doc.data() as Map<String, dynamic>?;
      final name = (data?['name'] ?? data?['displayName'] ?? 'مستخدم').toString();
      final image = (data?['profileImage'] ?? data?['photoURL'] ?? '')
          .toString()
          .trim();
      return _UserPreview(name: name, imageUrl: image);
    });
  }

  Future<void> _likePost(String postId) async {
    try {
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
                        final me = await _getUserPreview(widget.userId);
                        final post = PostModel(
                          id: '',
                          userId: widget.userId,
                          userName: me.name,
                          userImage: me.imageUrl.isEmpty ? null : me.imageUrl,
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
                      // Override theme's minSize (infinite width) since this button
                      // lives in a Row inside a Dialog (unbounded width).
                      minimumSize: const Size(120, 44),
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

  void _openCommentsSheet(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => _CommentsSheet(
        postId: postId,
        currentUserId: widget.userId,
        postRepository: _postRepository,
        userResolver: _getUserPreview,
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
                      _PostHeader(
                        post: post,
                        timeLabel: _formatTime(post.createdAt),
                        userResolver: _getUserPreview,
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
                              onTap: () => _likePost(post.id),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.comment_outlined,
                              label: 'Comment',
                              color: const Color(0xFF43A047),
                              onTap: () => _openCommentsSheet(post.id),
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
        heroTag: 'fab_social_feed',
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

class _UserPreview {
  final String name;
  final String imageUrl;

  const _UserPreview({required this.name, required this.imageUrl});
}

class _PostHeader extends StatelessWidget {
  final PostModel post;
  final String timeLabel;
  final Future<_UserPreview> Function(String uid) userResolver;

  const _PostHeader({
    required this.post,
    required this.timeLabel,
    required this.userResolver,
  });

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

    return FutureBuilder<_UserPreview>(
      future: userResolver(post.userId),
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
          backgroundColor: const Color(0xFF43A047),
          backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
          child:
              hasImage ? null : const Icon(Icons.person, color: Colors.white),
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

class _CommentsSheet extends StatefulWidget {
  final String postId;
  final String currentUserId;
  final PostRepository postRepository;
  final Future<_UserPreview> Function(String uid) userResolver;

  const _CommentsSheet({
    required this.postId,
    required this.currentUserId,
    required this.postRepository,
    required this.userResolver,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      final me = await widget.userResolver(widget.currentUserId);
      final comment = CommentModel(
        userId: widget.currentUserId,
        userName: me.name,
        userImage: me.imageUrl.isEmpty ? null : me.imageUrl,
        text: text,
        createdAt: DateTime.now(),
      );
      await widget.postRepository.addComment(widget.postId, comment);
      _controller.clear();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF404040),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Text(
                        'التعليقات',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFF2A2A2A)),
                Expanded(
                  child: StreamBuilder<PostModel?>(
                    stream: widget.postRepository.watchPost(widget.postId),
                    builder: (context, snapshot) {
                      final post = snapshot.data;
                      final comments = (post?.comments ?? [])
                        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const ModernLoading();
                      }

                      if (comments.isEmpty) {
                        return const Center(
                          child: EmptyState(
                            icon: Icons.chat_bubble_outline,
                            title: 'لا توجد تعليقات بعد',
                            subtitle: 'ابدأ أول تعليق على المنشور.',
                          ),
                        );
                      }

                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                        itemCount: comments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _CommentTile(
                            comment: comments[index],
                            userResolver: widget.userResolver,
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _isSending ? null : _send,
                        icon: _isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          textDirection: TextDirection.rtl,
                          decoration: const InputDecoration(
                            hintText: 'اكتب تعليقاً...',
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final Future<_UserPreview> Function(String uid) userResolver;

  const _CommentTile({required this.comment, required this.userResolver});

  @override
  Widget build(BuildContext context) {
    final cachedName = (comment.userName ?? '').trim();
    final cachedImage = (comment.userImage ?? '').trim();

    if (cachedName.isNotEmpty || cachedImage.isNotEmpty) {
      return _CommentBody(name: cachedName, imageUrl: cachedImage, text: comment.text);
    }

    return FutureBuilder<_UserPreview>(
      future: userResolver(comment.userId),
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
    return ModernCard(
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
