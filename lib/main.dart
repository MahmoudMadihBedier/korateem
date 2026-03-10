import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korateem/screens/login_screen.dart';
import 'package:korateem/screens/home_screen.dart';
import 'package:korateem/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:korateem/ui/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      home: StreamBuilder(
        stream: authService.userChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  final String uid;
  UserProfileScreen({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text('الملف الشخصي')),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        var data = snapshot.data!.data() as Map<String, dynamic>;
        return Scaffold(
          appBar: AppBar(title: Text('الملف الشخصي')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(data['profileImage'] ?? ''),
                ),
                SizedBox(height: 16),
                Text(
                  'الاسم: ${data['name'] ?? ''}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'البريد الإلكتروني: ${data['email'] ?? ''}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'رقم الهاتف: ${data['phone'] ?? ''}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'التقييم: ${data['rating'] ?? '0'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                // Add more fields as needed
              ],
            ),
          ),
        );
      },
    );
  }
}

class FieldsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الملاعب القريبة')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('fields').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var fields = snapshot.data!.docs;
          if (fields.isEmpty) {
            return Center(child: Text('لا توجد ملاعب قريبة'));
          }
          return ListView.builder(
            itemCount: fields.length,
            itemBuilder: (context, index) {
              var data = fields[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data['images']?[0] ?? ''),
                  ),
                  title: Text(
                    data['name'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    'الموقع: ${data['location'] ?? ''}\nالسعر: ${data['price'] ?? ''}',
                  ),
                  trailing: ElevatedButton(
                    child: Text('حجز'),
                    onPressed: () {
                      // Navigate to booking screen
                    },
                  ),
                  onTap: () {
                    // Navigate to field profile
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BookingScreen extends StatelessWidget {
  final String fieldId;
  BookingScreen({required this.fieldId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('حجز الملعب')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('fields')
            .doc(fieldId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var data = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اسم الملعب: ${data['name'] ?? ''}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'الموقع: ${data['location'] ?? ''}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'السعر: ${data['price'] ?? ''}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 24),
                Text(
                  'اختر موعد الحجز:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                // Example time slots
                Wrap(
                  spacing: 8,
                  children: [
                    for (var slot in ['6:00', '7:00', '8:00', '9:00'])
                      ElevatedButton(
                        child: Text(slot),
                        onPressed: () async {
                          // Save booking to Firestore
                          await FirebaseFirestore.instance
                              .collection('bookings')
                              .add({
                                'fieldId': fieldId,
                                'userId': Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                ).user?.uid,
                                'time': slot,
                                'status': 'pending',
                              });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تم الحجز بنجاح')),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
