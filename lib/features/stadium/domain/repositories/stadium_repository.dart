import '../entities/stadium_entity.dart';

abstract class IStadiumRepository {
  Stream<List<StadiumEntity>> watchAllStadiums();
  Future<StadiumEntity> getStadiumById(String id);
  Future<void> rateStadium(String stadiumId, double rating);
}
