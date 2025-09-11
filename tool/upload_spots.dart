// tool/upload_new_spots.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahargoyk/firebase_options.dart';

Future<void> main() async {
  // --- Firebaseの初期化 ---
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;
  print('Firebaseの初期化が完了しました。新しいスポットの登録を開始します...');

  // --- 1. 新しいスポットのリスト ---
  final spotsData = [
    {
      'title': '有馬温泉',
      'description': '日本最古の温泉地の一つで、金泉・銀泉の2種類の泉質が楽しめます。',
      'address': '兵庫県神戸市北区有馬町',
      'latitude': 34.7982278035815,
      'longitude':135.24947939162715,
      'imageUrl': 'assets/images/arima_onsen.png',
      'hours': '施設により異なる',
      'price': '施設により異なる',
      'access': '神戸電鉄有馬温泉駅からすぐ',
      'area': '北神',
      'genre': '温泉, 観光',
    },
    {
      'title': '南京町',
      'description': '横浜中華街、長崎新地中華街と並ぶ日本三大中華街の一つ。食べ歩きや散策が楽しめます。',
      'address': '兵庫県神戸市中央区栄町通1丁目',
      'latitude': 34.688188,
      'longitude': 135.18807,
      'imageUrl': 'assets/images/Nankinmachi_Plaza.png',
      'hours': '店舗により異なる',
      'price': '飲食代',
      'access': 'JR・阪神元町駅から徒歩5分',
      'area': '中央',
      'genre': 'グルメ, 観光',
    },
    {
      'title': '神戸須磨シーワールド',
      'description': 'シャチのパフォーマンスや、多様な海の生き物に出会える水族館。',
      'address': '兵庫県神戸市須磨区若宮町1丁目3-5',
      'latitude': 34.643972,
      'longitude': 135.128441,
      'imageUrl': 'assets/images/suma_se_world.png',
      'hours': '10:00～18:00',
      'price': '大人 3,100円',
      'access': 'JR須磨海浜公園駅から徒歩15分',
      'area': '須磨・垂水',
      'genre': '観光, 家族向け',
    },
    {
      'title': 'ノエビアスタジアム神戸',
      'description': 'Jリーグ「ヴィッセル神戸」やラグビーの試合が行われる多目的球技場。',
      'address': '兵庫県神戸市兵庫区御崎町1丁目2-2',
      'latitude': 34.654876,
      'longitude': 135.155891,
      'imageUrl': 'assets/images/Noevir_Stadium_Kobe.png',
      'hours': 'イベントにより異なる',
      'price': 'イベントにより異なる',
      'access': '地下鉄海岸線御崎公園駅から徒歩5分',
      'area': '中央',
      'genre': 'スポーツ',
    },
    {
      'title': '平磯海釣り公園',
      'description': '全長1,400mの釣り桟橋から釣りが楽しめる、子どもから大人まで楽しめる施設。',
      'address': '兵庫県神戸市垂水区平磯1-1-66',
      'latitude': 34.62732,
      'longitude': 135.068548,
      'imageUrl': 'assets/images/hiraiso_fish.png',
      'hours': '季節により異なる',
      'price': '大人1,000円（4時間）',
      'access': '山陽電鉄東垂水駅から徒歩3分',
      'area': '須磨・垂水',
      'genre': '自然, 家族向け',
    },
    {
      'title': 'しあわせの村',
      'description': '宿泊施設や温泉、キャンプ場など、多様なレジャー施設が揃う総合福祉ゾーン。',
      'address': '兵庫県神戸市北区しあわせの村1-1',
      'latitude': 34.71101,
      'longitude': 135.112455,
      'imageUrl': 'assets/images/siawasenomura.png',
      'hours': '施設により異なる',
      'price': '無料（一部施設は有料）',
      'access': 'JR三ノ宮駅からバスで約25分',
      'area': '北神',
      'genre': '自然, 家族向け',
    },
    {
      'title': '和田岬砲台',
      'description': '勝海舟が設計したと伝えられる、幕末の沿岸防衛施設。毎月見学会が開催されています。',
      'address': '兵庫県神戸市兵庫区和田崎町1-1-1',
      'latitude': 34.654868,
      'longitude': 135.15585,
      'imageUrl': 'assets/images/wadamisaki_bangaroll.png',
      'hours': '毎月第2木曜日',
      'price': '無料',
      'access': '地下鉄海岸線和田岬駅から徒歩4分',
      'area': '中央',
      'genre': '歴史, 観光',
    },
    {
      'title': 'みなとやま水族館',
      'description': '廃校になった小学校をリノベーションしたユニークな水族館。',
      'address': '兵庫県神戸市兵庫区雪御所町2-24-101 NATURE STUDIO EAST1F',
      'latitude': 34.68694,
      'longitude': 135.16362,
      'imageUrl': 'assets/images/minatoyama_suizokukan.png',
      'hours': '10:00～18:00',
      'price': '大人1,200円',
      'access': 'JR三ノ宮駅から市バスで20分、石井橋バス停から徒歩1分',
      'area': '中央',
      'genre': '観光, 家族向け',
    },
    {
      'title': '神戸三田プレミアム・アウトレット',
      'description': '約200の国内外ブランドが集まる、アメリカの街並みを再現したアウトレットモール。',
      'address': '兵庫県神戸市北区上津台7丁目3',
      'latitude': 34.860657,
      'longitude': 135.191852,
      'imageUrl': 'assets/images/kobesanda_autoreto.png',
      'hours': '10:00～20:00',
      'price': '無料',
      'access': '三田駅からバス',
      'area': '北神',
      'genre': 'ショッピング',
    },
    {
      'title': 'めんたいパーク神戸三田',
      'description': '明太子の製造工程が見学できるテーマパーク。出来たて明太子やフードコーナーも人気。',
      'address': '兵庫県神戸市北区赤松台1-7-1',
      'latitude': 34.874595,
      'longitude': 135.186572,
      'imageUrl': 'assets/images/Mentai_Park_Kobe_Sanda.png',
      'hours': '9:00～17:30',
      'price': '無料',
      'access': 'JR三田駅から無料巡回バス',
      'area': '北神',
      'genre': 'グルメ, 家族向け',
    },
    {
      'title': '神戸市立王子動物園',
      'description': 'ジャイアントパンダやコアラなど、人気動物に会える動物園。遊園地も併設されています。',
      'address': '兵庫県神戸市灘区王子町3丁目1',
      'latitude': 34.707198,
      'longitude': 135.208151,
      'imageUrl': 'assets/images/oji_zoo.png',
      'hours': '9:00～17:00（時期により異なる）',
      'price': '大人600円',
      'access': '阪急王子公園駅から徒歩3分',
      'area': '中央',
      'genre': '観光, 家族向け',
    },
  ];

  // --- 2. 各スポットを 'spots' コレクションに追加し、参照をリストに保存 ---
  final List<DocumentReference> spotRefs = [];
  final spotsCollection = firestore.collection('spots');

  for (final spotData in spotsData) {
    // 同じタイトルのスポットが既に存在するか確認（重複登録を避けるため）
    final existingSpot = await spotsCollection
        .where('title', isEqualTo: spotData['title'])
        .limit(1)
        .get();
    if (existingSpot.docs.isEmpty) {
      final spotRef = await spotsCollection.add(spotData);
      spotRefs.add(spotRef);
      print('  - スポットを追加しました: ${spotData['title']}');
    } else {
      spotRefs.add(existingSpot.docs.first.reference);
      print('  - 既存のスポットを使用します: ${spotData['title']}');
    }
  }

  print('🎉 すべてのデータの登録が完了しました。');
}