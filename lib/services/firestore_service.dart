// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_item.dart';
import '../models/course_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // (getSpots, getSpot, getCourses, getEvents は変更なし)
  // ...

  // ★★★ IDを指定して単一のコースと、それに含まれるスポット情報をまとめて取得 ★★★
  Future<CourseItem> getCourseWithSpots(String id) async {
    // まずコースのドキュメントを取得
    final courseDoc = await _db.collection('courses').doc(id).get();
    if (!courseDoc.exists) {
      throw Exception('Course not found');
    }

    final course = CourseItem.fromFirestore(courseDoc);

    // 次に、コース内のスポット参照リストを使って、各スポットの詳細情報を取得
    final List<ContentItem> spots = [];
    for (final spotRef in course.spotRefs) {
      final spotDoc = await spotRef.get();
      if (spotDoc.exists) {
        spots.add(ContentItem.fromFirestore(spotDoc));
      }
    }

    // 取得したスポット情報をコースオブジェクトに含めて返す
    return course.copyWith(spots: spots);
  }

  // (getCourseメソッドは残っていても問題ありません)
  Future<CourseItem> getCourse(String id) async {
    var snap = await _db.collection('courses').doc(id).get();
    return CourseItem.fromFirestore(snap);
  }
}
