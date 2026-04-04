import 'package:korateem/features/social/domain/entities/post_entity.dart';
import 'package:korateem/features/social/domain/repositories/post_repository.dart';
import 'package:korateem/features/social/domain/usecases/add_comment_usecase.dart';
import 'package:korateem/features/social/domain/usecases/create_post_usecase.dart';
import 'package:korateem/features/social/domain/usecases/toggle_like_usecase.dart';
import 'package:korateem/features/social/domain/usecases/watch_all_posts_usecase.dart';
import 'package:korateem/features/social/domain/usecases/watch_post_usecase.dart';
import 'package:korateem/features/user/data/models/user_model.dart';
import 'package:korateem/features/user/data/repositories/user_repository.dart';

class UserPreview {
  final String name;
  final String imageUrl;

  const UserPreview({required this.name, required this.imageUrl});
}

class UserPreviewResolver {
  final IUserRepository _userRepository;
  final Map<String, Future<UserPreview>> _cache = {};

  UserPreviewResolver(this._userRepository);

  Future<UserPreview> resolve(String uid) {
    final trimmed = uid.trim();
    if (trimmed.isEmpty) {
      return Future.value(const UserPreview(name: 'مستخدم', imageUrl: ''));
    }
    return _cache.putIfAbsent(trimmed, () async {
      final UserModel user = await _userRepository.getUser(trimmed);
      final name = user.name.trim().isEmpty ? 'مستخدم' : user.name.trim();
      final imageUrl = (user.profileImage ?? '').trim();
      return UserPreview(name: name, imageUrl: imageUrl);
    });
  }
}

class SocialFeedController {
  final String currentUserId;
  final WatchAllPostsUseCase _watchAllPosts;
  final WatchPostUseCase _watchPost;
  final ToggleLikeUseCase _toggleLike;
  final CreatePostUseCase _createPost;
  final AddCommentUseCase _addComment;
  final UserPreviewResolver _userPreviewResolver;

  SocialFeedController({
    required this.currentUserId,
    required IPostRepository postRepository,
    required IUserRepository userRepository,
  })  : _watchAllPosts = WatchAllPostsUseCase(postRepository),
        _watchPost = WatchPostUseCase(postRepository),
        _toggleLike = ToggleLikeUseCase(postRepository),
        _createPost = CreatePostUseCase(postRepository),
        _addComment = AddCommentUseCase(postRepository),
        _userPreviewResolver = UserPreviewResolver(userRepository);

  Stream<List<PostEntity>> watchFeed() => _watchAllPosts.execute();

  Stream<PostEntity?> watchPost(String postId) => _watchPost.execute(postId);

  Future<void> toggleLike(String postId) {
    return _toggleLike.execute(
      ToggleLikeRequest(postId: postId, userId: currentUserId),
    );
  }

  Future<void> createPost({
    required String content,
    String? imageUrl,
  }) async {
    final me = await _userPreviewResolver.resolve(currentUserId);
    return _createPost.execute(
      CreatePostRequest(
        userId: currentUserId,
        userName: me.name,
        userImage: me.imageUrl.isEmpty ? null : me.imageUrl,
        content: content,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    final me = await _userPreviewResolver.resolve(currentUserId);
    return _addComment.execute(
      AddCommentRequest(
        postId: postId,
        comment: CommentEntity(
          userId: currentUserId,
          userName: me.name,
          userImage: me.imageUrl.isEmpty ? null : me.imageUrl,
          text: text,
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<UserPreview> resolveUser(String uid) =>
      _userPreviewResolver.resolve(uid);
}
