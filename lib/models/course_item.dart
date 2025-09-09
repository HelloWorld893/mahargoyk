// lib/models/course_item.dart

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'content_item.dart'; // ★★★ この行を削除 ★★★

class CourseItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> genre;
  final String area;
  final List<DocumentReference> spotRefs; // スポットの参照を保持

  CourseItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.genre,
    required this.area,
    required this.spotRefs,
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
}
