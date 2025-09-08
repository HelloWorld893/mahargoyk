import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_item.dart';
import '../models/course_item.dart';

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

  // ★★★ このメソッドを新しく追加 ★★★
  // コースとそれに紐づくスポットのリストを取得する
  Future<CourseItem> getCourseWithSpots(String courseId) async {
    // 1. コースのドキュメントを取得
    final courseDoc = await _firestore
        .collection('courses')
        .doc(courseId)
        .get();

    // 2. そのコースの'spots'サブコレクションを取得
    final spotsSnapshot = await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('spots')
        .get();

    // 3. サブコレクションの各ドキュメントをContentItemに変換
    final spots = spotsSnapshot.docs
        .map((doc) => ContentItem.fromFirestore(doc))
        .toList();

    // 4. コース情報とスポットリストをまとめてCourseItemとして返す
    return CourseItem.fromFirestore(courseDoc, spots);
  }
}
