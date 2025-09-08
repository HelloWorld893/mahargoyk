import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahargoyk/firebase_options.dart';

Future<void> main() async {
  // --- Firebaseの初期化 ---
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;
  print('Firebaseの初期化が完了しました。シーサイドコースの登録を開始します...');

  // --- 1. 登録するコースの基本情報 ---
  final courseData = {
    'title': '気分爽快！神戸のシーサイドを満喫コース',
    'description': '須磨から舞子まで、神戸の美しい海岸線を巡るコースです。歴史や絶景、グルメも楽しめます。',
    'imageUrl':
        'https://storage.googleapis.com/mahargoyk-public-assets/course_kobe_seaside.jpg',
  };

  // --- 2. コースの情報を 'courses' コレクションに追加 ---
  final courseRef = await firestore.collection('courses').add(courseData);
  print('✅ コースを追加しました: ${courseRef.id}');

  // --- 3. コースに含まれるスポットのリスト (Wordファイルから抽出) ---
  final spots = [
    {
      'title': '須磨海岸',
      'description': '白砂青松の美しい海岸線が続く、市民の憩いの場。夏は海水浴客で賑わいます。',
      'address': '神戸市須磨区若宮町1丁目から須磨浦通6丁目',
      'latitude': 34.643675,
      'longitude': 135.124821,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_suma_beach.jpg',
      'hours': '24時間',
      'price': '無料',
      'access': 'JR須磨駅から徒歩10分',
    },
    {
      'title': '神戸市立須磨離宮公園',
      'description': '広大な敷地に噴水や花々が美しい、かつての皇室の別邸跡。バラの名所としても知られています。',
      'address': '神戸市須磨区東須磨1-1',
      'latitude': 34.653423,
      'longitude': 135.118216,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_suma_rikyu_park.jpg',
      'hours': '9:00～17:00',
      'price': '大人 400円',
      'access': 'バス停「離宮公園前」から徒歩5分',
    },
    {
      'title': '須磨寺',
      'description': '源平合戦ゆかりの古刹。境内には歴史的な見どころが多く、静かな時間を過ごせます。',
      'address': '神戸市須磨区須磨寺町4丁目6-8',
      'latitude': 34.650010,
      'longitude': 135.112215,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_suma_temple.jpg',
      'hours': '8:30～17:00',
      'price': '無料',
      'access': '山陽須磨寺駅から徒歩5分',
    },
    {
      'title': '須磨浦山上遊園',
      'description': 'ロープウェイとカーレーターを乗り継いで山上へ。神戸の街と海を一望できる絶景が待っています。',
      'address': '神戸市須磨区一ノ谷町5丁目3-2',
      'latitude': 34.643125,
      'longitude': 135.094447,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_sumaura_park.jpg',
      'hours': '10:00～17:00',
      'price': '往復料金 1,800円',
      'access': '山陽須磨浦公園駅からすぐ',
    },
    {
      'title': '五色塚古墳',
      'description': '明石海峡を望む丘の上に築かれた、兵庫県下最大の前方後円墳。壮大なスケールを体感できます。',
      'address': '神戸市垂水区五色山4丁目',
      'latitude': 34.630319,
      'longitude': 135.046655,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_goshikizuka.jpg',
      'hours': '9:00～17:00',
      'price': '無料',
      'access': '山陽霞ヶ丘駅から徒歩10分',
    },
  ];

  // --- 4. 各スポットの情報をサブコレクション 'spots' に追加 ---
  for (final spotData in spots) {
    await courseRef.collection('spots').add(spotData);
    print('  - スポットを追加しました: ${spotData['title']}');
  }

  print('🎉 すべてのデータの登録が完了しました。');
}
