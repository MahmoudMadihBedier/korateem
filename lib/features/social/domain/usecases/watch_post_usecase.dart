import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class WatchPostUseCase {
  final IPostRepository _repository;

  WatchPostUseCase(this._repository);

  Stream<PostEntity?> execute(String postId) => _repository.watchPost(postId);
}

