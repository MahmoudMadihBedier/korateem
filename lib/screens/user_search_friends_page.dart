import 'package:flutter/material.dart';
import '../ui/modern_components.dart';
import '../../features/user/data/models/user_model.dart';
import '../../features/user/data/repositories/user_repository.dart';

class UserSearchFriendsPage extends StatefulWidget {
  final String currentUserId;

  const UserSearchFriendsPage({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  State<UserSearchFriendsPage> createState() => _UserSearchFriendsPageState();
}

class _UserSearchFriendsPageState extends State<UserSearchFriendsPage> {
  late UserRepository _userRepository;
  late TextEditingController _searchController;
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
    _searchController = TextEditingController();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      _userRepository.searchUsers(query).listen((results) {
        setState(() {
          _searchResults = results
              .where((user) => user.id != widget.currentUserId)
              .toList();
          _isSearching = false;
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search error: $e'),
            backgroundColor: const Color(0xFFCF6679),
          ),
        );
      }
      setState(() => _isSearching = false);
    }
  }

  Future<void> _addFriend(String friendId, UserModel friend) async {
    try {
      final currentUser = await _userRepository.getUser(widget.currentUserId);
      final updatedFriends = List<String>.from(currentUser.friends);
      if (!updatedFriends.contains(friendId)) {
        updatedFriends.add(friendId);
        await _userRepository.updateUserProfile(
          UserModel(
            id: currentUser.id,
            name: currentUser.name,
            email: currentUser.email,
            phone: currentUser.phone,
            profileImage: currentUser.profileImage,
            friends: updatedFriends,
            rating: currentUser.rating,
          ),
        );
        if (mounted) {
          // Update UI to show friend is added
          setState(() {
            _searchResults.removeWhere((u) => u.id == friendId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${friend.name} added as friend!'),
              backgroundColor: const Color(0xFF43A047),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding friend: $e'),
            backgroundColor: const Color(0xFFCF6679),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: ModernAppBar(title: 'Find Friends'),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for friends...',
                hintStyle: const TextStyle(color: Color(0xFF808080)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF43A047)),
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
          ),
          // Search Results
          Expanded(
            child: _isSearching
                ? ModernLoading()
                : _searchResults.isEmpty
                ? EmptyState(
                    icon: _searchController.text.isEmpty
                        ? Icons.search
                        : Icons.person_off,
                    title: _searchController.text.isEmpty
                        ? 'Find Friends'
                        : 'No Users Found',
                    subtitle: _searchController.text.isEmpty
                        ? 'Search for friends to add'
                        : 'Try searching with different keywords',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ModernCard(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFF43A047),
                                backgroundImage: user.profileImage != null
                                    ? NetworkImage(user.profileImage!)
                                    : null,
                                child: user.profileImage == null
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    Text(
                                      user.email,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Color(0xFFFF9800),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          user.rating.toStringAsFixed(1),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _addFriend(user.id, user),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF43A047),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
