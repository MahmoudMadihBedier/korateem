import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:korateem/features/social/domain/entities/post_entity.dart';
import 'package:korateem/features/social/presentation/controllers/social_feed_controller.dart';
import 'package:korateem/features/social/presentation/formatters/relative_time_formatter.dart';
import 'package:korateem/features/social/presentation/widgets/post_header.dart';
import 'package:korateem/ui/modern_components.dart';

Future<void> showPostDetailsDialog(
  BuildContext context, {
  required SocialFeedController controller,
  required String postId,
  bool autofocusComment = false,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'post_details',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Provider.value(
          value: controller,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _PostDetailsCard(
                  postId: postId,
                  autofocusComment: autofocusComment,
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _PostDetailsCard extends StatefulWidget {
  final String postId;
  final bool autofocusComment;

  const _PostDetailsCard({required this.postId, required this.autofocusComment});

  @override
  State<_PostDetailsCard> createState() => _PostDetailsCardState();
}

class _PostDetailsCardState extends State<_PostDetailsCard> {
  final RelativeTimeFormatter _timeFormatter = const RelativeTimeFormatter();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    if (widget.autofocusComment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _commentFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _send(SocialFeedController social) async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    HapticFeedback.selectionClick();
    try {
      await social.addComment(postId: widget.postId, text: text);
      if (!mounted) return;
      _commentController.clear();
      HapticFeedback.lightImpact();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final social = context.read<SocialFeedController>();

    return ModernCard.glass(
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    'المنشور',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
            Flexible(
              child: StreamBuilder<PostEntity?>(
                stream: social.watchPost(widget.postId),
                builder: (context, snapshot) {
                  final post = snapshot.data;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: ModernLoading(),
                    );
                  }
                  if (post == null) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: EmptyState(
                        icon: Icons.error_outline,
                        title: 'لم يتم العثور على المنشور',
                        subtitle: 'قد يكون تم حذفه.',
                      ),
                    );
                  }

                  final timeLabel = _timeFormatter.formatArabic(post.createdAt);
                  final comments = post.comments.toList()
                    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    children: [
                      PostHeader(post: post, timeLabel: timeLabel),
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
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            'التعليقات (${comments.length})',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (comments.isEmpty)
                        Text(
                          'لا توجد تعليقات بعد. ابدأ أول تعليق.',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        ...comments.map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CommentBubble(comment: c),
                            )),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _sending ? null : () => _send(social),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      child: _sending
                          ? const SizedBox(
                              key: ValueKey('sending'),
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              key: ValueKey('send'),
                            ),
                    ),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocus,
                        minLines: 1,
                        maxLines: 4,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'اكتب تعليقاً...',
                        ),
                        onSubmitted: (_) => _send(social),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  final CommentEntity comment;

  const _CommentBubble({required this.comment});

  @override
  Widget build(BuildContext context) {
    final cachedName = (comment.userName ?? '').trim();
    final cachedImage = (comment.userImage ?? '').trim();
    final hasCached = cachedName.isNotEmpty || cachedImage.isNotEmpty;

    if (hasCached) {
      return _CommentBubbleBody(
        name: cachedName.isEmpty ? 'مستخدم' : cachedName,
        imageUrl: cachedImage,
        text: comment.text,
      );
    }

    return FutureBuilder<UserPreview>(
      future: context.read<SocialFeedController>().resolveUser(comment.userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return _CommentBubbleBody(
          name: (user?.name ?? 'مستخدم').trim(),
          imageUrl: (user?.imageUrl ?? '').trim(),
          text: comment.text,
        );
      },
    );
  }
}

class _CommentBubbleBody extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String text;

  const _CommentBubbleBody({
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
