import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../mappers/post_mapper.dart';
import '../models/post_model.dart';

class PostRepository implements IPostRepository {
  final CollectionReference posts = FirebaseFirestore.instance.collection(
    'posts',
  );
  final PostMapper _mapper;

  PostRepository({PostMapper mapper = const PostMapper()}) : _mapper = mapper;

  @override
  Future<void> createPost(CreatePostRequest request) async {
    final post = PostModel(
      id: '',
      userId: request.userId,
      userName: request.userName,
      userImage: request.userImage,
      content: request.content,
      imageUrl: request.imageUrl,
      createdAt: request.createdAt,
    );
    await posts.add(post.toMap());
  }

  @override
  Stream<List<PostEntity>> watchAllPosts() {
    return posts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PostModel.fromFirestore(doc))
                  .map(_mapper.toEntity)
                  .toList(),
        );
  }

  @override
  Future<void> toggleLike(ToggleLikeRequest request) async {
    if (request.postId.trim().isEmpty) {
      throw ArgumentError('postId must not be empty');
    }
    if (request.userId.trim().isEmpty) {
      throw ArgumentError('userId must not be empty');
    }

    final docRef = posts.doc(request.postId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final data = (snap.data() as Map<String, dynamic>?);
      final likes = List<String>.from((data?['likes'] ?? []) as List);
      final alreadyLiked = likes.contains(request.userId);
      tx.update(docRef, {
        'likes': alreadyLiked
            ? FieldValue.arrayRemove([request.userId])
            : FieldValue.arrayUnion([request.userId]),
      });
    });
  }

  @override
  Future<void> addComment(AddCommentRequest request) async {
    if (request.postId.trim().isEmpty) {
      throw ArgumentError('postId must not be empty');
    }
    await posts.doc(request.postId).update({
      'comments': FieldValue.arrayUnion(
        [_mapper.toCommentModel(request.comment).toMap()],
      ),
    });
  }

  @override
  Stream<PostEntity?> watchPost(String postId) {
    if (postId.trim().isEmpty) {
      return const Stream.empty();
    }
    return posts.doc(postId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return _mapper.toEntity(PostModel.fromFirestore(doc));
    });
  }

  @override
  Future<void> deletePost(String postId) async {
    if (postId.trim().isEmpty) {
      throw ArgumentError('postId must not be empty');
    }
    await posts.doc(postId).delete();
  }
}
