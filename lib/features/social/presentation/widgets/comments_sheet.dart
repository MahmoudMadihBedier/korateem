import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:korateem/features/social/domain/entities/post_entity.dart';
import 'package:korateem/features/social/presentation/controllers/social_feed_controller.dart';
import 'package:korateem/features/social/presentation/widgets/comment_tile.dart';
import 'package:korateem/ui/modern_components.dart';

class CommentsSheet extends StatefulWidget {
  final String postId;

  const CommentsSheet({super.key, required this.postId});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
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
      final social = context.read<SocialFeedController>();
      await social.addComment(postId: widget.postId, text: text);
      _controller.clear();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final social = context.read<SocialFeedController>();
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
                  child: StreamBuilder<PostEntity?>(
                    stream: social.watchPost(widget.postId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const ModernLoading();
                      }

                      final post = snapshot.data;
                      final comments = (post?.comments ?? []).toList()
                        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

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
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return AnimatedListItem(
                            delay: Duration(milliseconds: 18 * (index.clamp(0, 18))),
                            child: CommentTile(comment: comments[index]),
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
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
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
