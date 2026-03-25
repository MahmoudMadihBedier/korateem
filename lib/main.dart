import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:korateem/screens/login_screen.dart';
import 'package:korateem/screens/role_gate.dart';
import 'package:korateem/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:korateem/ui/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// Feature screen imports
import 'screens/user_profile_edit_page.dart';
import 'screens/user_profile_page.dart';
import 'screens/user_search_friends_enhanced_page.dart' as user_search_enhanced;
import 'screens/user_rating_page.dart';
import 'screens/social_feed_page.dart';
import 'screens/stadium_profile_page.dart';
import 'screens/stadium_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(create: (_) => AuthService(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return MaterialApp(
      title: 'كورة تيم',
      theme: korateemTheme,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: StreamBuilder(
        stream: authService.userChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            final uid = authService.currentUser?.uid ?? '';
            return RoleGate(uid: uid);
          } else {
            return  LoginScreen();
          }
        },
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/user-profile':
            final userId =
                (settings.arguments as Map<String, dynamic>?)?['userId'] ?? '';
            return MaterialPageRoute(
              builder: (_) => UserProfilePage(userId: userId),
            );
          case '/user-profile-edit':
            final userId =
                (settings.arguments as Map<String, dynamic>?)?['userId'] ?? '';
            return MaterialPageRoute(
              builder: (_) => UserProfileEditPage(userId: userId),
            );
          case '/search-friends':
            final args = settings.arguments as Map<String, dynamic>?;
            final currentUserId = args?['currentUserId'] ?? '';
            final currentUserName = args?['currentUserName'];
            final currentUserImage = args?['currentUserImage'];
            return MaterialPageRoute(
              builder: (_) => user_search_enhanced.UserSearchFriendsPage(
                currentUserId: currentUserId,
                currentUserName: currentUserName,
                currentUserImage: currentUserImage,
              ),
            );
          case '/search-friends-enhanced':
            final args = settings.arguments as Map<String, dynamic>?;
            final currentUserId = args?['currentUserId'] ?? '';
            final currentUserName = args?['currentUserName'];
            final currentUserImage = args?['currentUserImage'];
            return MaterialPageRoute(
              builder: (_) => user_search_enhanced.UserSearchFriendsPage(
                currentUserId: currentUserId,
                currentUserName: currentUserName,
                currentUserImage: currentUserImage,
              ),
            );
          case '/rate-user':
            final args = settings.arguments as Map<String, dynamic>?;
            final userId = args?['userId'] ?? '';
            final userName = args?['userName'] ?? '';
            return MaterialPageRoute(
              builder: (_) =>
                  UserRatingPage(userId: userId, userName: userName),
            );
          case '/social-feed':
            final userId =
                (settings.arguments as Map<String, dynamic>?)?['userId'] ?? '';
            return MaterialPageRoute(
              builder: (_) => SocialFeedPage(userId: userId),
            );
          case '/stadium-profile':
            final ownerId =
                (settings.arguments as Map<String, dynamic>?)?['ownerId'] ?? '';
            return MaterialPageRoute(
              builder: (_) => StadiumProfilePage(ownerId: ownerId),
            );
          case '/stadium-dashboard':
            final ownerId =
                (settings.arguments as Map<String, dynamic>?)?['ownerId'] ?? '';
            return MaterialPageRoute(
              builder: (_) => StadiumDashboardPage(ownerId: ownerId),
            );
          default:
            return null;
        }
      },
    );
  }
}
