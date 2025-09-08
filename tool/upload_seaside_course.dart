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
      // 最初のスポットなので、アクセス情報はコースの起点からのもの
      'access': 'JR須磨駅から徒歩【10分】',
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
      'access': '徒歩【10分】→神戸市バス「須磨駅前」→「離宮公園前」【10分】→徒歩【5分】',
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
      'access': '徒歩【10分】',
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
      'access': '徒歩【5分】→電車「須磨寺駅」→「須磨浦公園駅」【5分】',
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
      'access': '徒歩【5分】→電車「須磨浦公園駅」→「霞ヶ丘駅」【10分】→徒歩【10分】',
    },
    {
      'title': '孫文記念館(移情閣)',
      'description': '中国の革命家・孫文を記念する日本で唯一の博物館。国の重要文化財に指定されています。',
      'address': '神戸市垂水区東舞子町2051',
      'latitude': 34.630524,
      'longitude': 135.035257,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_sonbun_museum.jpg',
      'hours': '10:00～17:00',
      'price': '大人 300円',
      'access': '徒歩【15分】',
    },
    {
      'title': '舞子海上プロムナード',
      'description': '明石海峡大橋の橋桁内に設置された展望施設。海上47mからの景色は迫力満点です。',
      'address': '神戸市垂水区東舞子町2051',
      'latitude': 34.631064,
      'longitude': 135.034255,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_maiko_promenade.jpg',
      'hours': '9:00～18:00',
      'price': '大人 250円',
      'access': '徒歩【5分】',
    },
  ];

  // --- 4. 各スポットの情報をサブコレクション 'spots' に追加 ---
  for (final spotData in spots) {
    await courseRef.collection('spots').add(spotData);
    print('  - スポットを追加しました: ${spotData['title']}');
  }

  print('🎉 すべてのデータの登録が完了しました。');
}
