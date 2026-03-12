class PostEntity {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final List<String> likes;
  final int commentsCount;
  final DateTime createdAt;
  final String? userName;
  final String? userImage;

  PostEntity({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    this.likes = const [],
    this.commentsCount = 0,
    required this.createdAt,
    this.userName,
    this.userImage,
  });
}
