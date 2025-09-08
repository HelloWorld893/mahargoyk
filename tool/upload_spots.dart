import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
// firebase_options.dartへのパスを実際のプロジェクトに合わせてください
import 'package:mahargoyk/firebase_options.dart';

Future<void> main() async {
  // Firebaseを初期化するためのおまじない
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- ▼ ここに登録したいスポットのデータを追加・編集してください ▼ ---
  final spotsData = [
    {
      "title": "こども本の森 神戸",
      "description": "建築家・安藤忠雄氏からの寄附により、東遊園地にオープンした子どものための文化施設。",
      "address": "兵庫県神戸市中央区加納町6丁目1-1",
      "access": "各線三宮駅から徒歩約13分",
      "hours": "9:30～17:00 (休館日: 月曜日)",
      "price": "無料",
      "imageUrl": "https://example.com/path/to/kodomohonnomori.jpg", // 仮のURLです
      "latitude": 34.6893,
      "longitude": 135.1963,
    },
    {
      "title": "神戸ポートタワー",
      "description": "神戸のランドマークとして知られる美しいタワー。展望台からは360度のパノラマが広がります。",
      "address": "兵庫県神戸市中央区波止場町5-5",
      "access": "元町駅から徒歩約15分",
      "hours": "9:00～21:00",
      "price": "大人 700円",
      "imageUrl": "https://example.com/path/to/port_tower.jpg", // 仮のURLです
      "latitude": 34.6825,
      "longitude": 135.1860,
    },
    // --- ▼ Feel KOBEから追加したスポット ▼ ---
    {
      "title": "神戸布引ハーブ園／ロープウェイ",
      "description": "ロープウェイで向かう標高400mのテーマパーク。四季折々のハーブや花々が咲き誇り、神戸の街並みを一望できます。",
      "address": "兵庫県神戸市中央区北野町1-4-3",
      "access": "神戸市営地下鉄「新神戸駅」から徒歩約5分でロープウェイ「ハーブ園山麓駅」に到着",
      "hours": "10:00～17:00 (季節や曜日により変動あり)",
      "price": "往復ロープウェイ＋ハーブ園入園料 大人 1,800円",
      "imageUrl":
          "https://example.com/path/to/nunobiki_herb_gardens.jpg", // 仮のURLです
      "latitude": 34.7064,
      "longitude": 135.1953,
    },
    {
      "title": "神戸どうぶつ王国",
      "description": "動物たちとの距離が近い「花と動物と人とのふれあい共生パーク」。迫力満点のバードパフォーマンスは必見です。",
      "address": "兵庫県神戸市中央区港島南町7-1-9",
      "access": "ポートライナー「計算科学センター(神戸どうぶつ王国・「富岳」前)駅」下車すぐ",
      "hours": "10:00～17:00 (土日祝は17:30まで)",
      "price": "大人 2,200円",
      "imageUrl":
          "https://example.com/path/to/kobe_animal_kingdom.jpg", // 仮のURLです
      "latitude": 34.6565,
      "longitude": 135.2215,
    },
    {
      "title": "メリケンパーク",
      "description":
          "神戸ポートタワーや神戸海洋博物館など、神戸を象徴する建築物が集まる海辺の公園。「BE KOBE」のモニュメントは人気のフォトスポットです。",
      "address": "兵庫県神戸市中央区波止場町2",
      "access": "JR・阪神「元町駅」から徒歩約15分",
      "hours": "常時開放",
      "price": "無料",
      "imageUrl": "https://example.com/path/to/meriken_park.jpg", // 仮のURLです
      "latitude": 34.6819,
      "longitude": 135.1883,
    },
    {
      "title": "生田神社",
      "description":
          "1800年以上の歴史を持つ古社で、縁結びの神様として知られています。三宮の繁華街にありながら、境内は静かで厳かな雰囲気に包まれています。",
      "address": "兵庫県神戸市中央区下山手通1-2-1",
      "access": "JR・阪急・阪神「三宮駅」から徒歩約10分",
      "hours": "7:00頃～17:00頃 (季節により変動)",
      "price": "参拝無料",
      "imageUrl": "https://example.com/path/to/ikuta_shrine.jpg", // 仮のURLです
      "latitude": 34.6940,
      "longitude": 135.1925,
    },
    // --- ▲ ここまで ▲ ---
  ];
  // --- ▲ ここまで ▲ ---

  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('spots');

  print('Firebaseへのデータ登録を開始します...');

  // データを一つずつFirestoreに書き込む
  for (final data in spotsData) {
    try {
      await collection.add(data);
      print('  ✅ 登録成功: ${data['title']}');
    } catch (e) {
      print('  ❌ 登録失敗: ${data['title']} - エラー: $e');
    }
  }

  print('すべての処理が完了しました。Firebaseコンソールでデータを確認してください。');
}
