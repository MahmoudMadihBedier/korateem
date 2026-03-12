import '../entities/user_entity.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

abstract class IUserRepositoryBase {
  Future<UserEntity> getUser(String userId);
  Future<void> updateUserProfile(UserEntity user);
  Stream<List<UserEntity>> searchUsers(String query);
  Future<void> rateUser(String userId, double rating);
  Future<void> addFriend(String userId, String friendId);
  Future<void> removeFriend(String userId, String friendId);
}

class UserUseCaseRepository implements IUserRepositoryBase {
  final IUserRepository repository;

  UserUseCaseRepository(this.repository);

  @override
  Future<UserEntity> getUser(String userId) async {
    final model = await repository.getUser(userId);
    return _mapModelToEntity(model);
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    final model = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      profileImage: user.profileImage,
      friends: user.friends,
      rating: user.rating,
    );
    await repository.updateUserProfile(model);
  }

  @override
  Stream<List<UserEntity>> searchUsers(String query) {
    return repository
        .searchUsers(query)
        .map(
          (models) => models.map((model) => _mapModelToEntity(model)).toList(),
        );
  }

  @override
  Future<void> rateUser(String userId, double rating) async {
    await repository.rateUser(userId, rating);
  }

  @override
  Future<void> addFriend(String userId, String friendId) async {
    await repository.updateUserProfile(await repository.getUser(userId));
  }

  @override
  Future<void> removeFriend(String userId, String friendId) async {
    await repository.updateUserProfile(await repository.getUser(userId));
  }

  UserEntity _mapModelToEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      phone: model.phone,
      profileImage: model.profileImage,
      friends: model.friends,
      rating: model.rating,
    );
  }
}
