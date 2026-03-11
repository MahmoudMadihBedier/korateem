import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String location;
  final double rating;
  final int totalRatings;
  final String userType; // 'player', 'owner', 'both'
  final List<String> teams;
  final List<String> bookings;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.location,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.userType = 'player',
    this.teams = const [],
    this.bookings = const [],
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'] ?? '',
      location: data['location'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      totalRatings: data['totalRatings'] ?? 0,
      userType: data['userType'] ?? 'player',
      teams: List<String>.from(data['teams'] ?? []),
      bookings: List<String>.from(data['bookings'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'location': location,
      'rating': rating,
      'totalRatings': totalRatings,
      'userType': userType,
      'teams': teams,
      'bookings': bookings,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
