// このスクリプトはUIを含まないため、material.dartは不要です
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ★★★ エラー修正箇所 ★★★
// パッケージ名を基準としたパスに変更
import 'package:mahargoyk/firebase_options.dart';

// メインの処理
Future<void> main() async {
  // --- 1. Firebaseの初期化 ---
  // Flutterアプリと同様に、まずFirebaseを初期化する必要があります
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;

  print('Firebaseの初期化が完了しました。データ登録を開始します...');

  // --- 2. 登録したいコースの基本情報 ---
  final courseData = {
    'title': '神戸港満喫コース',
    'description': '港町神戸の景色とグルメを楽しむ、定番の観光コースです。',
    'imageUrl':
        'https://storage.googleapis.com/mahargoyk-public-assets/course_kobe_port.jpg',
  };

  // --- 3. コースの情報を 'courses' コレクションに追加 ---
  final courseRef = await firestore.collection('courses').add(courseData);
  print('✅ コースを追加しました: ${courseRef.id}');

  // --- 4. コースに含まれるスポットのリスト ---
  final spots = [
    {
      'title': '神戸海洋博物館',
      'description': '帆船の帆と波をイメージした白い屋根が特徴。海・船・港の歴史を楽しく学べます。',
      'address': '神戸市中央区波止場町2-2',
      'latitude': 34.6830,
      'longitude': 135.1882,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_kobe_maritime_museum.jpg',
      'hours': '10:00～18:00',
      'price': '大人 900円',
      'access': '元町駅から徒歩約15分',
    },
    {
      'title': '神戸ハーバーランドumie',
      'description': '旅の最後は、飲食店やショップが集まる大型商業施設へ。美しい神戸の海を眺めながら食事やお土産選びを楽しめます。',
      'address': '神戸市中央区東川崎町1丁目7-2',
      'latitude': 34.6796,
      'longitude': 135.1827,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_kobe_harborland.jpg',
      'hours': '10:00～21:00',
      'price': '入場無料',
      'access': 'JR神戸駅から徒歩約5分',
    },
  ];

  // --- 5. 各スポットの情報をサブコレクション 'spots' に追加 ---
  for (final spotData in spots) {
    await courseRef.collection('spots').add(spotData);
    print('  - スポットを追加しました: ${spotData['title']}');
  }

  print('🎉 すべてのデータの登録が完了しました。');
}
