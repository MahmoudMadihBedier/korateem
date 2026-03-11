import 'package:flutter/material.dart';
import 'package:korateem/screens/fields_screen.dart';
import 'package:korateem/screens/user_profile_screen.dart';
import 'package:korateem/screens/booking_screen.dart';
import 'package:korateem/screens/team_screen.dart';
import 'package:korateem/screens/owner_portal_screen.dart';
import 'package:provider/provider.dart';
import 'package:korateem/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final uid = authService.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(title: Text('الرئيسية')),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(authService.currentUser?.displayName ?? ''),
              accountEmail: Text(authService.currentUser?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  authService.currentUser?.photoURL ?? '',
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('الملف الشخصي'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(uid: uid),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.sports_soccer),
              title: Text('الملاعب'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FieldsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('الفرق'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TeamScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.business),
              title: Text('بوابة صاحب الملعب'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OwnerPortalScreen(ownerId: uid),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('تسجيل الخروج'),
              onTap: () async {
                await authService.signOut();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: Center(child: Text('مرحبا بك في كورة تيم')),
    );
  }
}
