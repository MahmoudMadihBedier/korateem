import '../../domain/entities/stadium_entity.dart';
import '../../domain/repositories/stadium_repository.dart';
import '../datasources/stadium_remote_datasource.dart';

class StadiumRepositoryImpl implements IStadiumRepository {
  final StadiumRemoteDataSource remoteDataSource;

  StadiumRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<StadiumEntity>> watchAllStadiums() {
    return remoteDataSource.getStadiums();
  }

  @override
  Future<StadiumEntity> getStadiumById(String id) {
    return remoteDataSource.getStadium(id);
  }

  @override
  Future<void> rateStadium(String stadiumId, double rating) {
    return remoteDataSource.rateStadium(stadiumId, rating);
  }
}
