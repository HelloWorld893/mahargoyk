import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahargoyk/firebase_options.dart'; // lib/firebase_options.dartをインポート

// Firebaseにモデルコースのデータを追加するためのスクリプト
void main() async {
  // Flutterアプリの初期化処理
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;

  // 追加したいモデルコースのデータ
  // Feel KOBEの「全天候型おでかけコース」の情報を基に作成
  final courseData = {
    'title': '天気を気にせず楽しめる！神戸の全天候型おでかけコース',
    'description':
        '季節や天気に左右されず、一年中いつでも楽しめる神戸のおでかけコース。どうぶつと触れ合える「神戸どうぶつ王国」から始まり、科学や宇宙を学べる「バンドー神戸青少年科学館」、とんぼ玉制作が体験できるミュージアムなどを巡ります。',
    'address': '兵庫県神戸市中央区',
    'access': 'ポートライナー三宮駅からスタート',
    'imageUrl':
        'https://storage.googleapis.com/mahargoyk-public-assets/course_rainy_day_kobe.jpg',
    'hours': '約7〜8時間',
    'price': '約5,000円（各施設の入館料・飲食代など）',
    'latitude': 34.6541, // 神戸どうぶつ王国の緯度
    'longitude': 135.2227, // 神戸どうぶつ王国の経度
  };

  try {
    // 'courses'コレクションに新しいドキュメントとしてデータを追加
    await firestore.collection('courses').add(courseData);
    print('Success: 新しいモデルコースのデータをFirestoreに追加しました。');
  } catch (e) {
    print('Error: Firestoreへのデータ追加中にエラーが発生しました: $e');
  }
}
