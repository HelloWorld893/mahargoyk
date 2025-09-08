// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getSpotData(String collectionName) {
    return _firestore.collection(collectionName).snapshots();
  }

  Future<DocumentSnapshot> getSpotDetail(
    String collectionName,
    String documentId,
  ) {
    return _firestore.collection(collectionName).doc(documentId).get();
  }
}
