import 'package:flutter/material.dart';
import 'package:korateem/screens/choose_role_page.dart';
import 'package:korateem/screens/home_screen.dart';
import 'package:korateem/services/user_role_service.dart';
import 'package:korateem/ui/modern_components.dart';

class RoleGate extends StatelessWidget {
  final String uid;
  const RoleGate({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final roleService = UserRoleService();
    return StreamBuilder<String?>(
      stream: roleService.watchRole(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: ModernLoading());
        }
        final role = snapshot.data;
        if (role == null || role.isEmpty) {
          return ChooseRolePage(uid: uid);
        }
        return HomeScreen(userRole: role);
      },
    );
  }
}

