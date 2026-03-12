import 'package:flutter/material.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search error: $e')));
      setState(() => _isSearching = false);
    }
  }

  Future<void> _addFriend(String friendId) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend added successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding friend: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Add Friends'),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          // Search Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Start searching for friends'
                          : 'No users found',
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.profileImage != null
                              ? NetworkImage(user.profileImage!)
                              : null,
                          child: user.profileImage == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(user.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                Text(' ${user.rating.toStringAsFixed(1)}'),
                              ],
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _addFriend(user.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
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
