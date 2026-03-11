import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IOwnerService {
  Future<void> addField(String ownerId, Map<String, dynamic> fieldData);
  Stream<QuerySnapshot> getOwnerFields(String ownerId);
}

class OwnerService implements IOwnerService {
  final CollectionReference fields = FirebaseFirestore.instance.collection(
    'fields',
  );

  @override
  Future<void> addField(String ownerId, Map<String, dynamic> fieldData) async {
    await fields.add({...fieldData, 'ownerId': ownerId});
  }

  @override
  Stream<QuerySnapshot> getOwnerFields(String ownerId) {
    return fields.where('ownerId', isEqualTo: ownerId).snapshots();
  }
}
