import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final List<String> likes;
  final List<CommentModel> comments;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    this.likes = const [],
    this.comments = const [],
    required this.createdAt,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      likes: List<String>.from(data['likes'] ?? []),
      comments: (data['comments'] ?? [])
          .map<CommentModel>((c) => CommentModel.fromMap(c))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments.map((c) => c.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class CommentModel {
  final String userId;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      userId: map['userId'] ?? '',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
