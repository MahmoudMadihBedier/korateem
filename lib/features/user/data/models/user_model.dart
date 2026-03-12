import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final List<String> friends;
  final double rating;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.friends = const [],
    this.rating = 0.0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    if (raw is! Map<String, dynamic>) {
      // Document missing or invalid; callers can decide how to handle defaults.
      return UserModel(
        id: doc.id,
        name: '',
        email: '',
        phone: '',
        profileImage: null,
        friends: const [],
        rating: 0.0,
      );
    }

    final data = raw;

    // Backward-compat: some data was mistakenly stored under `friends` as a map.
    final legacyProfile = data['friends'];
    final Map<String, dynamic>? legacy = legacyProfile is Map
        ? Map<String, dynamic>.from(legacyProfile)
        : null;

    String readString(Map<String, dynamic> map, String key) {
      final v = map[key];
      return v is String ? v : '';
    }

    double readDouble(Map<String, dynamic> map, String key) {
      final v = map[key];
      if (v is num) return v.toDouble();
      return 0.0;
    }

    final rawFriends = data['friends'];
    final List<String> parsedFriends = rawFriends is List
        ? rawFriends.whereType<String>().toList()
        : const <String>[];

    final Object? legacyProfileImage = legacy == null
        ? null
        : legacy['profileImage'];

    return UserModel(
      id: doc.id,
      name: readString(data, 'name').isNotEmpty
          ? readString(data, 'name')
          : (legacy == null ? '' : readString(legacy, 'name')),
      email: readString(data, 'email').isNotEmpty
          ? readString(data, 'email')
          : (legacy == null ? '' : readString(legacy, 'email')),
      phone: readString(data, 'phone').isNotEmpty
          ? readString(data, 'phone')
          : (legacy == null ? '' : readString(legacy, 'phone')),
      profileImage: (data['profileImage'] is String)
          ? data['profileImage'] as String
          : (legacyProfileImage is String ? legacyProfileImage : null),
      friends: parsedFriends,
      rating: (readDouble(data, 'rating') != 0.0)
          ? readDouble(data, 'rating')
          : (legacy == null ? 0.0 : readDouble(legacy, 'rating')),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'friends': friends,
      'rating': rating,
    };
  }
}
