import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

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
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _looksLikeNotFound(FirebaseException e) {
    final msg = (e.message ?? '').toLowerCase();
    return e.code == 'object-not-found' ||
        msg.contains('404') ||
        msg.contains('not found') ||
        msg.contains('does not exist');
  }

  String? _swapBucketSuffix(String bucket) {
    if (bucket.endsWith('.firebasestorage.app')) {
      return bucket.replaceFirst('.firebasestorage.app', '.appspot.com');
    }
    if (bucket.endsWith('.appspot.com')) {
      return bucket.replaceFirst('.appspot.com', '.firebasestorage.app');
    }
    return null;
  }

  List<FirebaseStorage> _candidateStorages() {
    final storages = <FirebaseStorage>[_storage];
    final app = Firebase.app();
    final bucket = app.options.storageBucket?.trim();
    final projectId = app.options.projectId.trim();

    final bucketNames = <String>{};

    void addBucketName(String? b) {
      final v = (b ?? '').trim();
      if (v.isEmpty) return;
      bucketNames.add(v);
    }

    // From FlutterFire config.
    addBucketName(bucket);
    addBucketName(_swapBucketSuffix(bucket ?? ''));

    // Derived from projectId (covers many Firebase projects).
    if (projectId.isNotEmpty) {
      addBucketName('$projectId.appspot.com');
      addBucketName('$projectId.firebasestorage.app');
    }

    for (final b in bucketNames) {
      storages.add(FirebaseStorage.instanceFor(app: app, bucket: 'gs://$b'));
    }

    // De-dup by bucket name.
    final seen = <String>{};
    return storages.where((s) => seen.add(s.bucket)).toList();
  }

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
    String imageUrl = '';

    if (imageFile != null) {
      FirebaseException? lastFirebaseError;
      Object? lastError;

      for (final storage in _candidateStorages()) {
        final ref = storage.ref().child('teams/${docRef.id}.jpg');
        try {
          if (kDebugMode) {
            debugPrint('Team image upload -> bucket=${storage.bucket} path=${ref.fullPath}');
          }
          final snap = await ref.putFile(
            imageFile,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          imageUrl = await snap.ref.getDownloadURL();
          lastFirebaseError = null;
          lastError = null;
          break;
        } on FirebaseException catch (e) {
          if (kDebugMode) {
            debugPrint(
              'Team image upload failed -> bucket=${storage.bucket} code=${e.code} message=${e.message}',
            );
          }
          lastFirebaseError = e;
          lastError = e;
          // If bucket is wrong/not enabled, some setups return 404. Try alternate bucket.
          if (_looksLikeNotFound(e)) {
            continue;
          }
          rethrow;
        } catch (e) {
          lastError = e;
          rethrow;
        }
      }

      if (imageUrl.trim().isEmpty) {
        // If we couldn't upload to any candidate bucket, surface the most helpful error.
        if (lastFirebaseError != null) throw lastFirebaseError;
        throw Exception(lastError ?? 'Failed to upload team image');
      }
    }

    final team = TeamModel(
      teamId: docRef.id,
      name: trimmedName,
      captainId: captainId,
      captainName: captainName.trim(),
      memberIds: memberIds,
      description: '',
      imageUrl: imageUrl,
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
