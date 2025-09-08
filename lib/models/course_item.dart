import 'package:cloud_firestore/cloud_firestore.dart';
import 'content_item.dart';

class CourseItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<ContentItem> spots; // スポットのリスト

  CourseItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.spots = const [],
  });

  factory CourseItem.fromFirestore(
    DocumentSnapshot doc,
    List<ContentItem> spots,
  ) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CourseItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      spots: spots, // 取得したスポットのリストをセット
    );
  }
}
