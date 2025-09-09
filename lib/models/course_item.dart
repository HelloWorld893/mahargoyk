// lib/models/course_item.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'content_item.dart'; // ★★★ content_itemをインポート ★★★

class CourseItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> genre;
  final String area;
  final List<DocumentReference> spotRefs;
  final List<ContentItem> spots; // ★★★ 取得したスポット情報を格納するリストを追加 ★★★

  CourseItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.genre,
    required this.area,
    required this.spotRefs,
    this.spots = const [], // ★★★ 初期値として空のリストを設定 ★★★
  });

  factory CourseItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CourseItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      genre: List<String>.from(data['genre'] ?? []),
      area: data['area'] ?? '',
      spotRefs: List<DocumentReference>.from(data['spots'] ?? []),
    );
  }

  // ★★★ スポット情報を追加して新しいインスタンスを返すメソッドを追加 ★★★
  CourseItem copyWith({List<ContentItem>? spots}) {
    return CourseItem(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      genre: genre,
      area: area,
      spotRefs: spotRefs,
      spots: spots ?? this.spots,
    );
  }
}
