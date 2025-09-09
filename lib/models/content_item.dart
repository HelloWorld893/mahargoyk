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
  final String area;
  final List<String> themes;
  final Timestamp? startDate; // イベント開始日を追加
  final Timestamp? endDate; // イベント終了日を追加

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
    required this.area,
    required this.themes,
    this.startDate, // コンストラクタに追加
    this.endDate, // コンストラクタに追加
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
      area: data['area'] ?? '',
      themes: List<String>.from(data['themes'] ?? []),
      startDate: data['startDate'], // Firestoreから読み込む
      endDate: data['endDate'], // Firestoreから読み込む
    );
  }
}
