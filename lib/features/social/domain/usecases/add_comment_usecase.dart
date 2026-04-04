import '../repositories/post_repository.dart';

class AddCommentUseCase {
  final IPostRepository _repository;

  AddCommentUseCase(this._repository);

  Future<void> execute(AddCommentRequest request) =>
      _repository.addComment(request);
}

