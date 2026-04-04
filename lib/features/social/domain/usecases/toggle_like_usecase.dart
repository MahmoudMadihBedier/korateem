import '../repositories/post_repository.dart';

class ToggleLikeUseCase {
  final IPostRepository _repository;

  ToggleLikeUseCase(this._repository);

  Future<void> execute(ToggleLikeRequest request) =>
      _repository.toggleLike(request);
}

