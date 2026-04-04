import '../repositories/post_repository.dart';

class CreatePostUseCase {
  final IPostRepository _repository;

  CreatePostUseCase(this._repository);

  Future<void> execute(CreatePostRequest request) =>
      _repository.createPost(request);
}

