// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_item.dart';
import '../models/course_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 全てのスポットを取得
  Stream<List<ContentItem>> getSpots() {
    return _db
        .collection('spots')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ContentItem.fromFirestore(doc))
              .toList(),
        );
  }

  // IDを指定して単一のスポットを取得
  Future<ContentItem> getSpot(String id) async {
    var snap = await _db.collection('spots').doc(id).get();
    return ContentItem.fromFirestore(snap);
  }

  // 全てのコースを取得
  Stream<List<CourseItem>> getCourses() {
    return _db.collection('courses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // ★★★ 修正箇所: fromFirestoreは引数を1つしか取らない ★★★
        return CourseItem.fromFirestore(doc);
      }).toList();
    });
  }

  // IDを指定して単一のコースを取得
  Future<CourseItem> getCourse(String id) async {
    var snap = await _db.collection('courses').doc(id).get();
    // ★★★ 修正箇所: fromFirestoreは引数を1つしか取らない ★★★
    return CourseItem.fromFirestore(snap);
  }

  // 全てのイベントを取得
  Stream<List<ContentItem>> getEvents() {
    return _db
        .collection('events')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ContentItem.fromFirestore(doc))
              .toList(),
        );
  }
}
