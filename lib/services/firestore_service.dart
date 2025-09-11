// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/content_item.dart';
import '../models/course_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  /// IDを指定して単一のコースと、それに含まれるスポット情報をまとめて取得
  Future<CourseItem> getCourseWithSpots(String id) async {
    // まずコースのドキュメントを取得
    final courseDoc = await _db.collection('courses').doc(id).get();
    if (!courseDoc.exists) {
      throw Exception('Course not found');
    }

    final course = CourseItem.fromFirestore(courseDoc);

    // 次に、コース内のスポット参照リストを使って、各スポットの詳細情報を取得
    final List<ContentItem> spots = [];
    if (course.spotRefs.isNotEmpty) {
      for (final spotRef in course.spotRefs) {
        final spotDoc = await spotRef.get();
        if (spotDoc.exists) {
          spots.add(ContentItem.fromFirestore(spotDoc));
        }
      }
    }

    // 取得したスポット情報をコースオブジェクトに含めて返す
    return course.copyWith(spots: spots);
  }

  Future<CourseItem> getCourse(String id) async {
    var snap = await _db.collection('courses').doc(id).get();
    return CourseItem.fromFirestore(snap);
  }

  // --- お気に入り機能のためのメソッド ---

  /// お気に入りに追加する
  Future<void> addFavorite(String type, String id) async {
    if (_user == null) return;
    final docRef = _db.collection(type).doc(id);
    await _db
        .collection('users')
        .doc(_user!.uid)
        .collection('favorites')
        .doc() // 自動ID
        .set({'ref': docRef, 'type': type, 'added_at': Timestamp.now()});
  }

  /// お気に入りから削除する
  Future<void> removeFavorite(String type, String id) async {
    if (_user == null) return;
    final docRef = _db.collection(type).doc(id);
    final querySnapshot = await _db
        .collection('users')
        .doc(_user!.uid)
        .collection('favorites')
        .where('ref', isEqualTo: docRef)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// アイテムがお気に入り登録済みか確認する
  Stream<bool> isFavorite(String type, String id) {
    if (_user == null) return Stream.value(false);
    final docRef = _db.collection(type).doc(id);
    return _db
        .collection('users')
        .doc(_user!.uid)
        .collection('favorites')
        .where('ref', isEqualTo: docRef)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  /// お気に入りリストを取得する
  Stream<List<DocumentSnapshot>> getFavorites(String type) {
    if (_user == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(_user!.uid)
        .collection('favorites')
        .where('type', isEqualTo: type)
        .orderBy('added_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final docFutures = snapshot.docs.map((doc) async {
            final ref = doc.data()['ref'] as DocumentReference;
            return await ref.get();
          }).toList();
          return await Future.wait(docFutures);
        });
  }
}
