import 'package:flutter/material.dart';
import '../services/user_service.dart';

class UserProfileScreen extends StatelessWidget {
  final String uid;
  UserProfileScreen({required this.uid});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    return FutureBuilder(
      future: userService.getUserProfile(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text('الملف الشخصي')),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        var data = (snapshot.data!.data() as Map<String, dynamic>?);
        return Scaffold(
          appBar: AppBar(title: Text('الملف الشخصي')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(data?['profileImage'] ?? ''),
                ),
                SizedBox(height: 16),
                Text('الاسم: ${data?['name'] ?? ''}', style: Theme.of(context).textTheme.bodyLarge),
                Text('البريد الإلكتروني: ${data?['email'] ?? ''}', style: Theme.of(context).textTheme.bodyLarge),
                Text('رقم الهاتف: ${data?['phone'] ?? ''}', style: Theme.of(context).textTheme.bodyLarge),
                Text('التقييم: ${data?['rating'] ?? '0'}', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        );
      },
    );
  }
}
