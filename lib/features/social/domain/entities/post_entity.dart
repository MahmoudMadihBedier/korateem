class PostEntity {
  final String id;
  final String userId;
  final String? userName;
  final String? userImage;
  final String content;
  final String? imageUrl;
  final List<String> likes;
  final List<CommentEntity> comments;
  final DateTime createdAt;

  PostEntity({
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

  int get commentsCount => comments.length;
}

class CommentEntity {
  final String userId;
  final String? userName;
  final String? userImage;
  final String text;
  final DateTime createdAt;

  CommentEntity({
    required this.userId,
    this.userName,
    this.userImage,
    required this.text,
    required this.createdAt,
  });
}
