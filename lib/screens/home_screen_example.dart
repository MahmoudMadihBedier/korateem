import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korateem/screens/user_profile_edit_page.dart';
import 'package:korateem/screens/user_search_friends_page.dart';
import 'package:korateem/screens/user_rating_page.dart';
import 'package:korateem/screens/social_feed_page.dart';
import 'package:korateem/screens/stadium_profile_page.dart';
import 'package:korateem/screens/stadium_dashboard_page.dart';

/// Example Home Screen with navigation to all new features
///
/// This is a reference implementation showing how to integrate
/// all the new features created for Korateem
class HomeScreenExample extends StatefulWidget {
  const HomeScreenExample({super.key});

  @override
  State<HomeScreenExample> createState() => _HomeScreenExampleState();
}

class _HomeScreenExampleState extends State<HomeScreenExample> {
  late String _userId;
  final bool _isStadiumOwner = false; // Set based on user role

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كورة تيم - Korateem'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Korateem',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Find teams, stadiums, and connect with players',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // User Features Section
            Text('My Profile', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                // Edit Profile
                _FeatureCard(
                  icon: Icons.person,
                  title: 'Edit Profile',
                  subtitle: 'Update your info',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserProfileEditPage(userId: _userId),
                      ),
                    );
                  },
                ),

                // Search Friends
                _FeatureCard(
                  icon: Icons.people,
                  title: 'Find Friends',
                  subtitle: 'Search & add',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            UserSearchFriendsPage(currentUserId: _userId),
                      ),
                    );
                  },
                ),

                // Social Feed
                _FeatureCard(
                  icon: Icons.feed,
                  title: 'Social Feed',
                  subtitle: 'Posts & updates',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SocialFeedPage(userId: _userId),
                      ),
                    );
                  },
                ),

                // Rate Users
                _FeatureCard(
                  icon: Icons.star,
                  title: 'Rate Users',
                  subtitle: 'Give reviews',
                  color: Colors.amber,
                  onTap: () => _showRateUserDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stadium Owner Features (Conditional)
            if (_isStadiumOwner) ...[
              Text(
                'Stadium Management',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  // Create Stadium
                  _FeatureCard(
                    icon: Icons.stadium,
                    title: 'New Stadium',
                    subtitle: 'Create profile',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StadiumProfilePage(ownerId: _userId),
                        ),
                      );
                    },
                  ),

                  // Stadium Dashboard
                  _FeatureCard(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    subtitle: 'Manage stadium',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StadiumDashboardPage(ownerId: _userId),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Feature Info
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Features',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    const FeatureInfo(
                      icon: Icons.person,
                      title: 'Complete Profile',
                      description: 'Add phone number and personal info',
                    ),
                    const SizedBox(height: 8),
                    const FeatureInfo(
                      icon: Icons.people,
                      title: 'Friend Network',
                      description: 'Search and add friends to your team',
                    ),
                    const SizedBox(height: 8),
                    const FeatureInfo(
                      icon: Icons.post_add,
                      title: 'Social Posts',
                      description: 'Create posts, like and comment',
                    ),
                    const SizedBox(height: 8),
                    const FeatureInfo(
                      icon: Icons.stadium,
                      title: 'Stadium Management',
                      description: 'Manage your stadium and bookings',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Debug Info (Remove in production)
            Opacity(
              opacity: 0.5,
              child: Text(
                'User ID: ${_userId.substring(0, 8)}...',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(context),
    );
  }

  void _showRateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate a User'),
        content: const Text('Select a user to rate their performance'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserRatingPage(
                    userId: 'targetUserId',
                    userName: 'Player Name',
                  ),
                ),
              );
            },
            child: const Text('Rate'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green[700]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircleAvatar(radius: 32, child: Icon(Icons.person, size: 40)),
                SizedBox(height: 12),
                Text(
                  'Korateem',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfileEditPage(userId: _userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Find Friends'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserSearchFriendsPage(currentUserId: _userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feed),
            title: const Text('Social Feed'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SocialFeedPage(userId: _userId),
                ),
              );
            },
          ),
          if (_isStadiumOwner)
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Stadium Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StadiumDashboardPage(ownerId: _userId),
                  ),
                );
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}

/// Feature Card Widget
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature Info Widget
class FeatureInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureInfo({super.key, 
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
