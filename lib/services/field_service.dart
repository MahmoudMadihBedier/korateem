import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IFieldService {
  Stream<QuerySnapshot> getFields();
  Future<DocumentSnapshot> getField(String fieldId);
}

class FieldService implements IFieldService {
  final CollectionReference fields = FirebaseFirestore.instance.collection(
    'fields',
  );

  @override
  Stream<QuerySnapshot> getFields() {
    return fields.snapshots();
  }

  @override
  Future<DocumentSnapshot> getField(String fieldId) async {
    if (fieldId.trim().isEmpty) {
      throw ArgumentError('fieldId must not be empty');
    }
    return await fields.doc(fieldId).get();
  }
}
