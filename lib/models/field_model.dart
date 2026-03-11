import 'package:cloud_firestore/cloud_firestore.dart';

class FieldModel {
  final String fieldId;
  final String name;
  final String ownerId;
  final String ownerName;
  final String location;
  final double latitude;
  final double longitude;
  final String description;
  final double pricePerHour;
  final List<String> images;
  final List<String> videos;
  final double rating;
  final int totalRatings;
  final List<String> amenities;
  final Map<String, bool> schedule; // day -> availability
  final DateTime createdAt;
  final bool isActive;

  FieldModel({
    required this.fieldId,
    required this.name,
    required this.ownerId,
    required this.ownerName,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.pricePerHour,
    this.images = const [],
    this.videos = const [],
    this.rating = 0.0,
    this.totalRatings = 0,
    this.amenities = const [],
    this.schedule = const {},
    required this.createdAt,
    this.isActive = true,
  });

  factory FieldModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FieldModel(
      fieldId: doc.id,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      location: data['location'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      pricePerHour: (data['pricePerHour'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      totalRatings: data['totalRatings'] ?? 0,
      amenities: List<String>.from(data['amenities'] ?? []),
      schedule: Map<String, bool>.from(data['schedule'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'pricePerHour': pricePerHour,
      'images': images,
      'videos': videos,
      'rating': rating,
      'totalRatings': totalRatings,
      'amenities': amenities,
      'schedule': schedule,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}
