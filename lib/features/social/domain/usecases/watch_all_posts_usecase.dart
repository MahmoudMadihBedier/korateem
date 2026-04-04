import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class WatchAllPostsUseCase {
  final IPostRepository _repository;

  WatchAllPostsUseCase(this._repository);

  Stream<List<PostEntity>> execute() => _repository.watchAllPosts();
}

