import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String ratingId;
  final String fieldId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final List<String> photos;
  final DateTime createdAt;

  RatingModel({
    required this.ratingId,
    required this.fieldId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.photos = const [],
    required this.createdAt,
  });

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      ratingId: doc.id,
      fieldId: data['fieldId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fieldId': fieldId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
