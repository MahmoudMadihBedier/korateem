import '../entities/post_entity.dart';

class CreatePostRequest {
  final String userId;
  final String? userName;
  final String? userImage;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  CreatePostRequest({
    required this.userId,
    this.userName,
    this.userImage,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });
}

class ToggleLikeRequest {
  final String postId;
  final String userId;

  ToggleLikeRequest({required this.postId, required this.userId});
}

class AddCommentRequest {
  final String postId;
  final CommentEntity comment;

  AddCommentRequest({required this.postId, required this.comment});
}

abstract class IPostRepository {
  Stream<List<PostEntity>> watchAllPosts();
  Stream<PostEntity?> watchPost(String postId);

  Future<void> createPost(CreatePostRequest request);
  Future<void> toggleLike(ToggleLikeRequest request);
  Future<void> addComment(AddCommentRequest request);
  Future<void> deletePost(String postId);
}

