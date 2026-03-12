import 'package:flutter/material.dart';
import 'package:korateem/screens/fields_screen.dart';
import 'package:korateem/screens/user_profile_screen.dart';
import 'package:korateem/screens/team_screen.dart';
import 'package:korateem/screens/owner_portal_screen.dart';
import 'package:provider/provider.dart';
import 'package:korateem/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final uid = authService.currentUser?.uid ?? '';

    final screens = [
      _buildHomeScreen(),
      FieldsScreen(),
      TeamScreen(),
      UserProfileScreen(uid: uid),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('كورة تيم'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  authService.currentUser?.photoURL ??
                      'https://via.placeholder.com/40',
                ),
                radius: 18,
              ),
            ),
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
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
      drawer: _buildDrawer(context, authService, uid),
    );
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero banner
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحبا بك',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'احجز ملعبك المفضل الآن',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          // Quick action cards
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'الخدمات السريعة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                _buildQuickActionCard(
                  icon: Icons.sports_soccer,
                  title: 'ابحث عن ملاعب',
                  subtitle: 'اكتشف الملاعب القريبة منك',
                  color: Color(0xFF1E88E5),
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                SizedBox(height: 12),
                _buildQuickActionCard(
                  icon: Icons.people,
                  title: 'شكل فريقك',
                  subtitle: 'انضم أو أنشئ فريق جديد',
                  color: Color(0xFF43A047),
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                SizedBox(height: 12),
                _buildQuickActionCard(
                  icon: Icons.business,
                  title: 'إدارة ملعبك',
                  subtitle: 'إذا كنت صاحب ملعب',
                  color: Color(0xFFFF9800),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OwnerPortalScreen(
                        ownerId:
                            Provider.of<AuthService>(
                              context,
                              listen: false,
                            ).currentUser?.uid ??
                            '',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'الميزات الجديدة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                _buildQuickActionCard(
                  icon: Icons.person_add,
                  title: 'ابحث عن صديق',
                  subtitle: 'ابحث عن لاعبين آخرين',
                  color: Color(0xFF8E24AA),
                  onTap: () {
                    final userId =
                        Provider.of<AuthService>(
                          context,
                          listen: false,
                        ).currentUser?.uid ??
                        '';
                    Navigator.pushNamed(
                      context,
                      '/search-friends',
                      arguments: {'currentUserId': userId},
                    );
                  },
                ),
                SizedBox(height: 12),
                _buildQuickActionCard(
                  icon: Icons.star,
                  title: 'قيّم لاعب',
                  subtitle: 'أعط رأيك في أداء اللاعبين',
                  color: Color(0xFFF57C00),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/rate-user',
                      arguments: {'userId': '', 'userName': ''},
                    );
                  },
                ),
                SizedBox(height: 12),
                _buildQuickActionCard(
                  icon: Icons.feed,
                  title: 'المنشورات',
                  subtitle: 'شارك وتفاعل مع المنشورات',
                  color: Color(0xFF0097A7),
                  onTap: () {
                    final userId =
                        Provider.of<AuthService>(
                          context,
                          listen: false,
                        ).currentUser?.uid ??
                        '';
                    Navigator.pushNamed(
                      context,
                      '/social-feed',
                      arguments: {'userId': userId},
                    );
                  },
                ),
                SizedBox(height: 12),
                _buildQuickActionCard(
                  icon: Icons.edit,
                  title: 'تعديل ملفك',
                  subtitle: 'حدّث بيانات ملفك الشخصي',
                  color: Color(0xFF5E35B1),
                  onTap: () {
                    final userId =
                        Provider.of<AuthService>(
                          context,
                          listen: false,
                        ).currentUser?.uid ??
                        '';
                    Navigator.pushNamed(
                      context,
                      '/user-profile-edit',
                      arguments: {'userId': userId},
                    );
                  },
                ),
                SizedBox(height: 12),
                _buildQuickActionCard(
                  icon: Icons.sports_soccer,
                  title: 'ملعب جديد',
                  subtitle: 'أضف ملعبك إلى القائمة',
                  color: Color(0xFF00695C),
                  onTap: () {
                    final userId =
                        Provider.of<AuthService>(
                          context,
                          listen: false,
                        ).currentUser?.uid ??
                        '';
                    Navigator.pushNamed(
                      context,
                      '/stadium-profile',
                      arguments: {'ownerId': userId},
                    );
                  },
                ),
                SizedBox(height: 12),
                _buildQuickActionCard(
                  icon: Icons.dashboard,
                  title: 'لوحة التحكم',
                  subtitle: 'إدارة ملاعبك والحجوزات',
                  color: Color(0xFF455A64),
                  onTap: () {
                    final userId =
                        Provider.of<AuthService>(
                          context,
                          listen: false,
                        ).currentUser?.uid ??
                        '';
                    Navigator.pushNamed(
                      context,
                      '/stadium-dashboard',
                      arguments: {'ownerId': userId},
                    );
                  },
                ),
                SizedBox(height: 24),
                Text(
                  'الميزات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                _buildFeatureItem('⚡', 'حجز سريع وسهل'),
                _buildFeatureItem('📍', 'ملاعب قريبة من موقعك'),
                _buildFeatureItem('👥', 'تكوين فرق وتنظيم مباريات'),
                _buildFeatureItem('⭐', 'تقييمات وآراء المستخدمين'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    AuthService authService,
    String uid,
  ) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              authService.currentUser?.displayName ?? 'المستخدم',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(authService.currentUser?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                authService.currentUser?.photoURL ??
                    'https://via.placeholder.com/100',
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, color: Color(0xFF1E88E5)),
            title: Text('الملف الشخصي'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 3);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.business, color: Color(0xFFFF9800)),
            title: Text('بوابة صاحب الملعب'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OwnerPortalScreen(ownerId: uid),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey),
            title: Text('الإعدادات'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.grey),
            title: Text('عن التطبيق'),
            onTap: () => Navigator.pop(context),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await authService.signOut();
            },
          ),
        ],
      ),
    );
  }
}
