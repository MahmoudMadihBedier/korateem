import '../../domain/entities/post_entity.dart';
import '../models/post_model.dart';

class PostMapper {
  const PostMapper();

  PostEntity toEntity(PostModel model) {
    return PostEntity(
      id: model.id,
      userId: model.userId,
      userName: model.userName,
      userImage: model.userImage,
      content: model.content,
      imageUrl: model.imageUrl,
      likes: model.likes,
      comments: model.comments.map(_toCommentEntity).toList(),
      createdAt: model.createdAt,
    );
  }

  CommentEntity _toCommentEntity(CommentModel model) {
    return CommentEntity(
      userId: model.userId,
      userName: model.userName,
      userImage: model.userImage,
      text: model.text,
      createdAt: model.createdAt,
    );
  }

  CommentModel toCommentModel(CommentEntity entity) {
    return CommentModel(
      userId: entity.userId,
      userName: entity.userName,
      userImage: entity.userImage,
      text: entity.text,
      createdAt: entity.createdAt,
    );
  }
}

