import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userImage;
  final String content;
  final String? imageUrl;
  final List<String> likes;
  final List<CommentModel> comments;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userImage,
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
      userName: data['userName'],
      userImage: data['userImage'],
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
      if (userName != null) 'userName': userName,
      if (userImage != null) 'userImage': userImage,
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
  final String? userName;
  final String? userImage;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.userId,
    this.userName,
    this.userImage,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      userId: map['userId'] ?? '',
      userName: map['userName'],
      userImage: map['userImage'],
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      if (userName != null) 'userName': userName,
      if (userImage != null) 'userImage': userImage,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
