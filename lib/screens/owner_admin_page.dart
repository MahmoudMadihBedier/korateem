import 'package:flutter/material.dart';
import 'package:korateem/features/social/data/models/post_model.dart';
import 'package:korateem/features/social/data/repositories/post_repository.dart';
import 'package:korateem/features/user/data/models/user_model.dart';
import 'package:korateem/features/user/data/repositories/user_repository.dart';
import 'package:korateem/ui/modern_components.dart';

class OwnerAdminPage extends StatefulWidget {
  final String ownerId;
  const OwnerAdminPage({super.key, required this.ownerId});

  @override
  State<OwnerAdminPage> createState() => _OwnerAdminPageState();
}

class _OwnerAdminPageState extends State<OwnerAdminPage> {
  final UserRepository _userRepository = UserRepository();
  final PostRepository _postRepository = PostRepository();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة الإدارة'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'اللاعبين'),
              Tab(text: 'المنشورات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<List<UserModel>>(
              stream: _userRepository.getAllUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const ModernLoading();
                final users = snapshot.data!;
                if (users.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outline,
                    title: 'لا يوجد لاعبين',
                    subtitle: 'لم يتم العثور على مستخدمين',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final u = users[i];
                    final hasImage =
                        (u.profileImage ?? '').trim().isNotEmpty;
                    return ModernCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          backgroundImage:
                              hasImage ? NetworkImage(u.profileImage!) : null,
                          child: hasImage
                              ? null
                              : Text(
                                  u.name.isNotEmpty ? u.name[0] : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        title: Text(u.name.isNotEmpty ? u.name : 'مستخدم'),
                        subtitle: Text(
                          u.email.isNotEmpty ? u.email : u.phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            StreamBuilder<List<PostModel>>(
              stream: _postRepository.getAllPosts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const ModernLoading();
                final posts = snapshot.data!;
                if (posts.isEmpty) {
                  return const EmptyState(
                    icon: Icons.feed_outlined,
                    title: 'لا توجد منشورات',
                    subtitle: 'لم يتم العثور على منشورات حتى الآن',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final p = posts[i];
                    final author = (p.userName ?? '').trim().isNotEmpty
                        ? p.userName!.trim()
                        : 'مستخدم ${p.userId.substring(0, 6)}';
                    return ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  author,
                                  style: Theme.of(context).textTheme.titleSmall,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.content,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
