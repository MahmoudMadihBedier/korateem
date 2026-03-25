import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

abstract class IPostRepository {
  Future<void> createPost(PostModel post);
  Stream<List<PostModel>> getAllPosts();
  Future<void> likePost(String postId, String userId);
  Future<void> addComment(String postId, CommentModel comment);
  Stream<PostModel?> watchPost(String postId);
}

class PostRepository implements IPostRepository {
  final CollectionReference posts = FirebaseFirestore.instance.collection(
    'posts',
  );

  @override
  Future<void> createPost(PostModel post) async {
    await posts.add(post.toMap());
  }

  @override
  Stream<List<PostModel>> getAllPosts() {
    return posts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList(),
        );
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    if (postId.trim().isEmpty) {
      throw ArgumentError('postId must not be empty');
    }
    final docRef = posts.doc(postId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final data = (snap.data() as Map<String, dynamic>?);
      final likes = List<String>.from((data?['likes'] ?? []) as List);
      final alreadyLiked = likes.contains(userId);
      tx.update(docRef, {
        'likes': alreadyLiked
            ? FieldValue.arrayRemove([userId])
            : FieldValue.arrayUnion([userId]),
      });
    });
  }

  @override
  Future<void> addComment(String postId, CommentModel comment) async {
    if (postId.trim().isEmpty) {
      throw ArgumentError('postId must not be empty');
    }
    await posts.doc(postId).update({
      'comments': FieldValue.arrayUnion([comment.toMap()]),
    });
  }

  @override
  Stream<PostModel?> watchPost(String postId) {
    if (postId.trim().isEmpty) {
      return const Stream.empty();
    }
    return posts.doc(postId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return PostModel.fromFirestore(doc);
    });
  }
}
