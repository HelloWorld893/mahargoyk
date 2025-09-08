// lib/models/content_item.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ContentItem {
  final String id;
  final String title;
  final String description;
  final String address;
  final String access;
  final String imageUrl;
  final String hours;
  final String price;
  final double latitude;
  final double longitude;
  // ★★★ フィルター用のフィールドを追加 ★★★
  final String area;
  final List<String> themes;

  ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.access,
    required this.imageUrl,
    required this.hours,
    required this.price,
    required this.latitude,
    required this.longitude,
    // ★★★ コンストラクタにも追加 ★★★
    required this.area,
    required this.themes,
  });

  factory ContentItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ContentItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      access: data['access'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      hours: data['hours'] ?? '',
      price: data['price'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      // ★★★ Firestoreのデータから読み込むように追加 ★★★
      area: data['area'] ?? '',
      themes: List<String>.from(data['themes'] ?? []),
    );
  }
}
