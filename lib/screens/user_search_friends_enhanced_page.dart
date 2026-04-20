import 'package:flutter/material.dart';
import '../ui/modern_components.dart';
import '../../features/user/data/repositories/user_repository.dart';
import '../../features/user/data/repositories/friend_request_repository.dart';
import '../../features/user/data/models/user_model.dart';
import '../../features/user/data/models/friend_request_model.dart';

class UserSearchFriendsPage extends StatefulWidget {
  final String currentUserId;
  final String? currentUserName;
  final String? currentUserImage;

  const UserSearchFriendsPage({
    super.key,
    required this.currentUserId,
    this.currentUserName,
    this.currentUserImage,
  });

  @override
  State<UserSearchFriendsPage> createState() => _UserSearchFriendsPageState();
}

class _UserSearchFriendsPageState extends State<UserSearchFriendsPage>
    with SingleTickerProviderStateMixin {
  late final UserRepository _userRepository;
  late final FriendRequestRepository _friendRequestRepository;
  late final TextEditingController _searchController;
  late TabController _tabController;
  late UserModel _currentUser;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
    _friendRequestRepository = FriendRequestRepository();
    _searchController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _userRepository.getUser(widget.currentUserId);
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  Future<void> _sendFriendRequest(
    String recipientId,
    String recipientName,
  ) async {
    try {
      await _friendRequestRepository.sendFriendRequest(
        widget.currentUserId,
        recipientId,
        _currentUser.name,
        _currentUser.profileImage ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Friend request sent to $recipientName'),
            backgroundColor: const Color(0xFF43A047),
          ),
        );
      }

      setState(() {});
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

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: ModernAppBar(title: 'البحث عن الأصدقاء'),
        body: ModernLoading(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: ModernAppBar(title: 'البحث عن الأصدقاء'),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث عن لاعب...',
                hintStyle: const TextStyle(color: Color(0xFF808080)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF43A047)),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
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
          ),

          // Tab Bar
          Container(
            color: const Color(0xFF1E1E1E),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF43A047),
              unselectedLabelColor: const Color(0xFF808080),
              labelColor: Colors.white,
              tabs: const [
                Tab(text: 'أصدقائي'),
                Tab(text: 'جميع المستخدمين'),
                Tab(text: 'الطلبات المعلقة'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyFriendsTab(),
                _buildAllUsersTab(),
                _buildPendingRequestsTab()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllUsersTab() {
    return StreamBuilder<List<UserModel>>(
      stream: _searchQuery.isEmpty
          ? _userRepository.getAllUsers()
          : _userRepository.searchUsers(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ModernLoading();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return EmptyState(
            icon: Icons.person_search,
            title: 'لا توجد نتائج',
            subtitle: _searchQuery.isEmpty
                ? 'لا توجد مستخدمين آخرين'
                : 'لم نجد مستخدمين يطابقون البحث',
          );
        }

        final users = snapshot.data!
            .where((user) => user.id != widget.currentUserId)
            .toList();

        if (users.isEmpty) {
          return EmptyState(
            icon: Icons.person_search,
            title: 'لا توجد نتائج',
            subtitle: 'لم نجد مستخدمين آخرين للإضافة',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final isFriend = _currentUser.friends.contains(user.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ModernCard(
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF43A047),
                      backgroundImage:
                          user.profileImage != null &&
                              user.profileImage!.isNotEmpty
                          ? NetworkImage(user.profileImage!)
                          : null,
                      child:
                          user.profileImage == null ||
                              user.profileImage!.isEmpty
                          ? Text(
                              user.name.isNotEmpty ? user.name[0] : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: const Color(0xFF808080)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (i) {
                              return Icon(
                                i < user.rating.toInt()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 12,
                                color: const Color(0xFFFFA500),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    // Action Button
                    if (isFriend)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF43A047),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'صديق',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => _sendFriendRequest(user.id, user.name),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF43A047),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'إضافة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyFriendsTab() {
    return StreamBuilder<List<UserModel>>(
      stream: _userRepository.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ModernLoading();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return EmptyState(
            icon: Icons.people_outline,
            title: 'لا يوجد أصدقاء',
            subtitle: 'لم تقم بإضافة أصدقاء بعد',
          );
        }

        final friends = snapshot.data!
            .where((user) => _currentUser.friends.contains(user.id))
            .where((user) =>
                _searchQuery.isEmpty ||
                user.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        if (friends.isEmpty) {
          return EmptyState(
            icon: Icons.people_outline,
            title: 'لا يوجد أصدقاء',
            subtitle: _searchQuery.isEmpty
                ? 'لم تقم بإضافة أصدقاء بعد'
                : 'لم نجد أصدقاء يطابقون البحث',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final user = friends[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ModernCard(
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF43A047),
                      backgroundImage: (user.profileImage != null &&
                              user.profileImage!.isNotEmpty)
                          ? NetworkImage(user.profileImage!)
                          : null,
                      child: (user.profileImage == null ||
                              user.profileImage!.isEmpty)
                          ? Text(
                              user.name.isNotEmpty ? user.name[0] : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: const Color(0xFF808080)),
                          ),
                        ],
                      ),
                    ),

                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF43A047)),
                      ),
                      child: const Text(
                        'صديق',
                        style: TextStyle(
                          color: Color(0xFF43A047),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingRequestsTab() {
    return StreamBuilder<List<FriendRequestModel>>(
      stream: _friendRequestRepository.getPendingRequests(widget.currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ModernLoading();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return EmptyState(
            icon: Icons.mail_outline,
            title: 'لا توجد طلبات',
            subtitle: 'لا توجد طلبات صداقة معلقة',
          );
        }

        final requests = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ModernCard(
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF43A047),
                      backgroundImage: request.senderImage.isNotEmpty
                          ? NetworkImage(request.senderImage)
                          : null,
                      child: request.senderImage.isEmpty
                          ? Text(
                              request.senderName.isNotEmpty
                                  ? request.senderName[0]
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.senderName,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            'طلب صداقة معلق',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: const Color(0xFF808080)),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Accept
                        GestureDetector(
                          onTap: () async {
                            try {
                              await _friendRequestRepository
                                  .acceptFriendRequest(
                                    request.id,
                                    request.senderId,
                                    request.recipientId,
                                  );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تم قبول طلب ${request.senderName}',
                                    ),
                                    backgroundColor: const Color(0xFF43A047),
                                  ),
                                );
                              }
                              setState(() {});
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('خطأ: $e'),
                                    backgroundColor: const Color(0xFFCF6679),
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF43A047),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'قبول',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // Reject
                        GestureDetector(
                          onTap: () async {
                            try {
                              await _friendRequestRepository
                                  .rejectFriendRequest(request.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تم رفض طلب ${request.senderName}',
                                    ),
                                    backgroundColor: const Color(0xFFCF6679),
                                  ),
                                );
                              }
                              setState(() {});
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('خطأ: $e'),
                                    backgroundColor: const Color(0xFFCF6679),
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF404040),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'رفض',
                              style: TextStyle(
                                color: Color(0xFF808080),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
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
    );
  }
}
