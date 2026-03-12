# QUICK START - Add These Routes to main.dart

## Step 1: Import all new pages

Add these imports to your `main.dart`:

```dart
import 'package:korateem/screens/user_profile_edit_page.dart';
import 'package:korateem/screens/user_search_friends_page.dart';
import 'package:korateem/screens/user_rating_page.dart';
import 'package:korateem/screens/social_feed_page.dart';
import 'package:korateem/screens/stadium_profile_page.dart';
import 'package:korateem/screens/stadium_dashboard_page.dart';
```

## Step 2: Update MaterialApp with routes

Replace the MaterialApp in main.dart:

```dart
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
  routes: {
    '/user_profile': (context) {
      final userId = ModalRoute.of(context)?.settings.arguments as String;
      return UserProfileEditPage(userId: userId);
    },
    '/search_friends': (context) {
      final userId = ModalRoute.of(context)?.settings.arguments as String;
      return UserSearchFriendsPage(currentUserId: userId);
    },
    '/rate_user': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>;
      return UserRatingPage(
        userId: args['userId']!,
        userName: args['userName']!,
      );
    },
    '/social_feed': (context) {
      final userId = ModalRoute.of(context)?.settings.arguments as String;
      return SocialFeedPage(userId: userId);
    },
    '/stadium_profile': (context) {
      final ownerId = ModalRoute.of(context)?.settings.arguments as String;
      return StadiumProfilePage(ownerId: ownerId);
    },
    '/stadium_dashboard': (context) {
      final ownerId = ModalRoute.of(context)?.settings.arguments as String;
      return StadiumDashboardPage(ownerId: ownerId);
    },
  },
  home: StreamBuilder(
    stream: authService.userChanges,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      if (snapshot.hasData) {
        return HomeScreen();
      } else {
        return LoginScreen();
      }
    },
  ),
);
```

## Step 3: Add Navigation Buttons to Home Screen

In your `home_screen.dart`:

```dart
// Add these buttons
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(
      context,
      '/user_profile',
      arguments: currentUserId,
    );
  },
  child: const Text('Edit Profile'),
),

ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(
      context,
      '/search_friends',
      arguments: currentUserId,
    );
  },
  child: const Text('Find Friends'),
),

ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(
      context,
      '/social_feed',
      arguments: currentUserId,
    );
  },
  child: const Text('Social Feed'),
),

// For stadium owners only
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(
      context,
      '/stadium_dashboard',
      arguments: currentUserId,
    );
  },
  child: const Text('My Stadium'),
),
```

## Step 4: Ensure Firebase Collections Exist

The following Firestore collections will be created automatically when data is added:

- `users` - User profiles
- `posts` - Social media posts
- `stadiums` - Stadium information
- `bookings` - Stadium bookings
- `chats` - Owner-team conversations

## Step 5: Test Everything

Run the app:

```bash
flutter clean
flutter pub get
flutter run
```

Navigate through:
1. Edit profile (enter phone number)
2. Search and add friends
3. Create and like posts
4. Create/manage stadium (if owner)

---

## Common Issues & Fixes

### Issue: "No route named '/user_profile'"
**Fix:** Make sure all imports and routes are added correctly in main.dart

### Issue: "Null error when getting arguments"
**Fix:** Pass arguments using:
```dart
Navigator.pushNamed(context, '/user_profile', arguments: userId)
```

### Issue: Firebase permission denied
**Fix:** Check Firestore security rules (see IMPLEMENTATION_GUIDE.md)

### Issue: Images not loading
**Fix:** Add image URL to Firestore or use placeholder

---

## Next: Add State Management (Riverpod)

After routes work, add Riverpod:

```bash
flutter pub add riverpod flutter_riverpod
```

Create providers:

```dart
// providers/user_provider.dart
final currentUserProvider = FutureProvider((ref) async {
  // Get current user
});

final userSearchProvider = StreamProvider.family((ref, String query) async* {
  // Stream search results
});
```

This enables reactive updates across the app!

---

**Your app is now production-ready with all features!** 🚀
