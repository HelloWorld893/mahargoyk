// tool/upload_events.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // ★★★ ここのタイプミスを修正 ★★★
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:mahargoyk/firebase_options.dart';

// イベントデータを定義
final List<Map<String, dynamic>> events = [
  {
    'title': '2025年度コレクション展Ⅱ 日本画との対話―自然と人間',
    'description':
        '東山魁夷、髙山辰雄、西田眞人ら、四季折々の美しい自然に自らとの接点を築き、その中に在る人間の存在を描き出してきた画家たちによる珠玉の作品群約50点を展示。',
    'address': '兵庫県神戸市灘区岩屋中町4丁目2番7号 BBプラザ2F',
    'access': '阪神岩屋駅すぐ南側 / JR灘駅より南へ徒歩約3分 / 阪急王子公園駅より南へ徒歩約10分',
    'imageUrl': 'https://www.kobe-bunka.jp/c/art/18786200/images/1_1.jpg',
    'hours': '10:00～17:00 (入館は16:30まで)',
    'price': '一般 500円 / 大学生以下無料',
    'latitude': 34.7063,
    'longitude': 135.2215,
    'area': '灘・東灘',
    'genre': 'イベント',
    'startDate': Timestamp.fromDate(DateTime(2025, 9, 2)),
    'endDate': Timestamp.fromDate(DateTime(2025, 10, 26)),
  },
  {
    'title': '神戸ルミナリエ',
    'description': '阪神・淡路大震災の犠牲者への鎮魂と、都市の復興・再生への夢と希望を託して開催される光の祭典。',
    'address': '兵庫県神戸市中央区加納町6丁目',
    'access': 'JR・阪神元町駅から徒歩約5分',
    'imageUrl': 'https://example.com/luminarie.jpg',
    'hours': '薄暮〜21:30 (日によって変動あり)',
    'price': '無料（一部有料エリアあり）',
    'latitude': 34.6901,
    'longitude': 135.1915,
    'area': '三宮・元町',
    'genre': 'イベント',
    'startDate': Timestamp.fromDate(DateTime(2025, 12, 5)),
    'endDate': Timestamp.fromDate(DateTime(2025, 12, 14)),
  },
  {
    'title': 'みなとこうべ海上花火大会',
    'description': '神戸の夜景をバックに、約1万5000発の花火が打ち上げられる関西最大級の花火大会。',
    'address': '神戸港（新港突堤〜メリケンパーク沖）',
    'access': 'JR・阪神元町駅から徒歩約15分',
    'imageUrl': 'https://example.com/hanabi.jpg',
    'hours': '19:30～20:30',
    'price': '無料（協賛席あり）',
    'latitude': 34.6830,
    'longitude': 135.1900,
    'area': 'メリケンパーク・ハーバーランド',
    'genre': 'イベント',
    'startDate': Timestamp.fromDate(DateTime(2025, 8, 3)),
    'endDate': Timestamp.fromDate(DateTime(2025, 8, 3)),
  },
  {
    'title': '神戸ジャズストリート',
    'description':
        '国内外のプロのジャズミュージシャンが神戸に集結し、市内のライブハウスやホールで演奏を繰り広げる日本最古のジャズフェスティバル。',
    'address': '神戸市内の各ライブハウス、ホテルなど',
    'access': '各会場による',
    'imageUrl': 'https://example.com/jazz.jpg',
    'hours': '各会場による',
    'price': '有料（チケット制）',
    'latitude': 34.6946,
    'longitude': 135.1921,
    'area': '北野・新神戸',
    'genre': 'イベント',
    'startDate': Timestamp.fromDate(DateTime(2025, 10, 12)),
    'endDate': Timestamp.fromDate(DateTime(2025, 10, 13)),
  },
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference eventsCollection = firestore.collection('events');

  // 既存のデータをクリア（必要に応じてコメントを外してください）
  // print('既存のイベントデータを削除します...');
  // final snapshot = await eventsCollection.get();
  // for (var doc in snapshot.docs) {
  //   await doc.reference.delete();
  // }
  // print('既存のイベントデータを削除しました。');

  print('イベントデータの登録を開始します...');
  for (final eventData in events) {
    await eventsCollection.add(eventData);
    print('"${eventData['title']}" を登録しました。');
  }

  print('すべてのイベントデータの登録が完了しました。');
}
