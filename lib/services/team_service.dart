import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ITeamService {
  Future<void> createTeam(String name, List<String> members);
  Stream<QuerySnapshot> getTeams();
}

class TeamService implements ITeamService {
  final CollectionReference teams = FirebaseFirestore.instance.collection(
    'teams',
  );

  @override
  Future<void> createTeam(String name, List<String> members) async {
    await teams.add({'name': name, 'members': members});
  }

  @override
  Stream<QuerySnapshot> getTeams() {
    return teams.snapshots();
  }
}
