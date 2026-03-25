import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';

import '../models/team_model.dart';

abstract class ITeamService {
  Future<String> createTeam({
    required String name,
    required String captainId,
    required String captainName,
    required List<String> memberIds,
    File? imageFile,
  });
  Stream<QuerySnapshot> getTeams();
  Stream<QuerySnapshot> getTeamsForUser(String userId);
}

class TeamService implements ITeamService {
  final CollectionReference teams = FirebaseFirestore.instance.collection(
    'teams',
  );

  @override
  Future<String> createTeam({
    required String name,
    required String captainId,
    required String captainName,
    required List<String> memberIds,
    File? imageFile,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('name must not be empty');
    }
    if (captainId.trim().isEmpty) {
      throw ArgumentError('captainId must not be empty');
    }
    if (memberIds.length != 5) {
      throw ArgumentError('memberIds must contain exactly 5 players');
    }
    if (!memberIds.contains(captainId)) {
      throw ArgumentError('captainId must be one of memberIds');
    }

    final docRef = teams.doc();
    String imageData = '';
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      // Firestore document limit is ~1MB; keep a safe margin.
      if (bytes.lengthInBytes > 900 * 1024) {
        throw Exception(
          'حجم الصورة كبير جداً. اختار صورة أصغر (يفضل أقل من 900KB).',
        );
      }
      imageData = base64Encode(bytes);
    }

    final team = TeamModel(
      teamId: docRef.id,
      name: trimmedName,
      captainId: captainId,
      captainName: captainName.trim(),
      memberIds: memberIds,
      description: '',
      imageUrl: '',
      imageData: imageData,
      createdAt: DateTime.now(),
    );

    await docRef.set(team.toFirestore());
    return docRef.id;
  }

  @override
  Stream<QuerySnapshot> getTeams() {
    return teams.snapshots();
  }

  @override
  Stream<QuerySnapshot> getTeamsForUser(String userId) {
    if (userId.trim().isEmpty) {
      return const Stream<QuerySnapshot>.empty();
    }
    return teams.where('memberIds', arrayContains: userId).snapshots();
  }
}
