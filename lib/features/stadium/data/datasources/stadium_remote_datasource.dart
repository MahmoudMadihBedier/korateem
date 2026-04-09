import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stadium_model.dart';

abstract class StadiumRemoteDataSource {
  Stream<List<StadiumModel>> getStadiums();
  Future<StadiumModel> getStadium(String id);
  Future<void> rateStadium(String stadiumId, double rating);
}

class StadiumRemoteDataSourceImpl implements StadiumRemoteDataSource {
  final FirebaseFirestore firestore;

  StadiumRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<StadiumModel>> getStadiums() {
    return firestore.collection('stadiums').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StadiumModel.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<StadiumModel> getStadium(String id) async {
    final doc = await firestore.collection('stadiums').doc(id).get();
    if (doc.exists) {
      return StadiumModel.fromFirestore(doc.data()!, doc.id);
    } else {
      throw Exception('Stadium not found');
    }
  }

  @override
  Future<void> rateStadium(String stadiumId, double rating) async {
    await firestore.collection('stadiums').doc(stadiumId).update({'rating': rating});
  }
}
