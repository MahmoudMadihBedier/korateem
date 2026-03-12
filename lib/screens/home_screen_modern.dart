import 'package:flutter/material.dart';
import 'package:korateem/screens/fields_screen.dart';
import 'package:korateem/screens/user_profile_screen.dart';
import 'package:korateem/screens/team_screen.dart';
import 'package:korateem/screens/owner_portal_screen.dart';
import 'package:provider/provider.dart';
import 'package:korateem/services/auth_service.dart';
import 'package:korateem/ui/modern_components.dart';

/// Modern Home Screen with new UI/UX design
class HomeScreenModern extends StatefulWidget {
  const HomeScreenModern({super.key});

  @override
  State<HomeScreenModern> createState() => _HomeScreenModernState();
}

class _HomeScreenModernState extends State<HomeScreenModern> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final uid = authService.currentUser?.uid ?? '';
    final userName = authService.currentUser?.displayName ?? 'مستخدم';

    final screens = [
      _buildModernHomeScreen(context, uid, userName, authService),
      FieldsScreen(),
      TeamScreen(),
      UserProfileScreen(uid: uid),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        title: Text('كورة تيم'),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  authService.currentUser?.photoURL ??
                      'https://via.placeholder.com/40',
                ),
                radius: 20,
                backgroundColor: Color(0xFF43A047),
              ),
            ),
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'الملاعب',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'الفرق'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  /// Modern home screen with feature cards
  Widget _buildModernHomeScreen(
    BuildContext context,
    String uid,
    String userName,
    AuthService authService,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero banner with gradient
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'مرحبا بك يا $userName',
                    style: Theme.of(
                      context,
                    ).textTheme.displayMedium?.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اكتشف الملاعب والفرق والمنشورات',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Quick action cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                _buildSearchBar(context),
                SizedBox(height: 24),

                // New features section
                Text(
                  'الميزات الجديدة',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 12),

                // Feature grid
                _buildFeatureGrid(context, uid),

                SizedBox(height: 24),

                // Existing features section
                Text(
                  'الميزات الأساسية',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 12),

                _buildMainFeatures(context, uid, authService),
              ],
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Search bar component
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'ابحث عن ملعب أو لاعب أو فريق...',
          hintStyle: TextStyle(color: Color(0xFF808080)),
          prefixIcon: Icon(Icons.search, color: Color(0xFF43A047)),
          filled: true,
          fillColor: Color(0xFF2A2A2A),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(color: Colors.white),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  /// Feature grid
  Widget _buildFeatureGrid(BuildContext context, String uid) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                icon: Icons.person_add,
                title: 'ابحث عن لاعب',
                subtitle: 'جد زملاء الفريق',
                color: Color(0xFF8E24AA),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/search-friends',
                  arguments: {'currentUserId': uid},
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                context,
                icon: Icons.star,
                title: 'قيّم لاعب',
                subtitle: 'امنح تقييمات',
                color: Color(0xFFF57C00),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/rate-user',
                  arguments: {'userId': '', 'userName': ''},
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                icon: Icons.feed,
                title: 'المنشورات',
                subtitle: 'شارك أخبارك',
                color: Color(0xFF0097A7),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/social-feed',
                  arguments: {'userId': uid},
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                context,
                icon: Icons.edit,
                title: 'ملفك',
                subtitle: 'حدّث بيانات',
                color: Color(0xFF5E35B1),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/user-profile-edit',
                  arguments: {'userId': uid},
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                icon: Icons.sports_soccer,
                title: 'ملعب جديد',
                subtitle: 'أضف ملعبك',
                color: Color(0xFF00695C),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/stadium-profile',
                  arguments: {'ownerId': uid},
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                context,
                icon: Icons.dashboard,
                title: 'لوحة التحكم',
                subtitle: 'إدارة ملاعب',
                color: Color(0xFF455A64),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/stadium-dashboard',
                  arguments: {'ownerId': uid},
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Individual feature card
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ModernCard(
      padding: EdgeInsets.all(12),
      backgroundColor: Color(0xFF2A2A2A),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Main features section
  Widget _buildMainFeatures(
    BuildContext context,
    String uid,
    AuthService authService,
  ) {
    return Column(
      children: [
        ModernCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ابحث عن ملاعب',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'اكتشف الملاعب القريبة منك',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.sports_soccer, color: Color(0xFF43A047), size: 40),
            ],
          ),
        ),
        SizedBox(height: 12),
        ModernCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'شكل فريقك',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'انضم أو أنشئ فريق جديد',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.people, color: Color(0xFF43A047), size: 40),
            ],
          ),
        ),
        SizedBox(height: 12),
        ModernCard(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OwnerPortalScreen(ownerId: uid)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'إدارة ملعبك',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'إذا كنت صاحب ملعب',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.business, color: Color(0xFF43A047), size: 40),
            ],
          ),
        ),
      ],
    );
  }
}
