import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:korateem/features/social/domain/entities/post_entity.dart';
import 'package:korateem/features/social/domain/repositories/post_repository.dart';
import 'package:korateem/features/social/presentation/controllers/social_feed_controller.dart';
import 'package:korateem/features/social/presentation/formatters/relative_time_formatter.dart';
import 'package:korateem/features/social/presentation/widgets/create_post_card.dart';
import 'package:korateem/features/social/presentation/widgets/social_post_card.dart';
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

  void _openCreatePostComposer() {
    final textController = TextEditingController();
    final focusNode = FocusNode();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (focusNode.hasFocus) return;
          focusNode.requestFocus();
        });

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.45,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              bool posting = false;
              return StatefulBuilder(
                builder: (context, setModalState) {
                  Future<void> submit() async {
                    if (posting) return;
                    final text = textController.text.trim();
                    if (text.isEmpty) return;
                    setModalState(() => posting = true);
                    try {
                      await _controller.createPost(content: text);
                      if (!mounted) return;
                      Navigator.of(this.context).pop();
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نشر المنشور بنجاح!'),
                          backgroundColor: Color(0xFF43A047),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text('حدث خطأ: $e'),
                          backgroundColor: const Color(0xFFCF6679),
                        ),
                      );
                    } finally {
                      try {
                        setModalState(() => posting = false);
                      } catch (_) {}
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: ModernCard.glass(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                      child: ListView(
                        controller: scrollController,
                        children: [
                          Center(
                            child: Container(
                              width: 44,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                'منشور جديد',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ModernCard(
                            glassy: false,
                            backgroundColor: const Color(0xFF121212),
                            padding: const EdgeInsets.all(12),
                            child: TextField(
                              controller: textController,
                              focusNode: focusNode,
                              minLines: 4,
                              maxLines: 10,
                              textDirection: TextDirection.rtl,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'بماذا تفكر؟',
                              ),
                              onChanged: (_) => setModalState(() {}),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                '${textController.text.trim().length} حرف',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed:
                                    posting || textController.text.trim().isEmpty
                                        ? null
                                        : submit,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(140, 46),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  child: posting
                                      ? const SizedBox(
                                          key: ValueKey('posting'),
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'نشر',
                                          key: ValueKey('post'),
                                        ),
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
        );
      },
    ).whenComplete(() {
      textController.dispose();
      focusNode.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: StreamBuilder<List<PostEntity>>(
            stream: _controller.watchFeed(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ModernLoading();
              }

              if (snapshot.hasError) {
                return EmptyState(
                  icon: Icons.error_outline,
                  title: 'خطأ في تحميل المنشورات',
                  subtitle: 'حدث خطأ أثناء تحميل المنشورات',
                  actionLabel: 'إعادة المحاولة',
                  onAction: () => setState(() {}),
                );
              }

              final posts = snapshot.data ?? const <PostEntity>[];

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: posts.isEmpty ? 2 : posts.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FeedTopBar(
                          onNotificationsTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('الإشعارات قريباً.'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        CreatePostCard(onCreate: _openCreatePostComposer),
                      ],
                    );
                  }

                  if (posts.isEmpty && index == 1) {
                    return EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'لا توجد منشورات بعد',
                      subtitle: 'كن أول من ينشر!',
                      actionLabel: 'إنشاء منشور',
                      onAction: _openCreatePostComposer,
                    );
                  }

                  final post = posts[index - 1];
                  final timeLabel = _timeFormatter.formatArabic(post.createdAt);

                  return AnimatedListItem(
                    delay: Duration(
                      milliseconds: 24 * ((index - 1).clamp(0, 12)),
                    ),
                    child: SocialPostCard(
                      post: post,
                      currentUserId: widget.userId,
                      timeLabel: timeLabel,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeedTopBar extends StatelessWidget {
  final VoidCallback onNotificationsTap;

  const _FeedTopBar({required this.onNotificationsTap});

  @override
  Widget build(BuildContext context) {
    return ModernCard.glass(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Text(
            'كورة تيم',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onNotificationsTap,
            icon: Badge(
              child: Icon(
                Icons.notifications_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
