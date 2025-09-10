// tool/upload_rural_course_reordered.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahargoyk/firebase_options.dart';

Future<void> main() async {
  // --- Firebaseの初期化 ---
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;
  print('Firebaseの初期化が完了しました。農村・里山コースの登録を開始します...');

  // --- 1. コースに含まれるスポットのリスト（指定された順番）---
  final spotsData = [
    {
      'title': '弓削牧場',
      'description': '市街地からわずか20分の自然豊かな牧場。自家加工の濃厚な牛乳やチーズが楽しめます。',
      'address': '兵庫県神戸市北区山田町下谷上西丸山5-2',
      'latitude': 34.746451,
      'longitude': 135.173792,
      'imageUrl':
          'assets/images/Yuge_Farm.png',
      'hours': '11:00～16:30', // チーズハウスヤルゴイ
      'price': '〜3,000円',
      'access': '神戸市営地下鉄 谷上駅から車で10分',
      'area': '西神・北神',
      'genre': 'グルメ, 自然',
    },
    {
      'title': 'あいな里山公園',
      'description': '四季折々の花や生き物に触れられる国営公園。茅葺きの建物や棚田など、昔ながらの日本の風景を感じられます。',
      'address': '兵庫県神戸市北区山田町藍那字田代',
      'latitude': 34.720188,
      'longitude': 135.109012,
      'imageUrl':
          'assets/images/Aina_Satoyama_Park.png',
      'hours': '9:30～17:00（時期により異なる）',
      'price': '大人 450円',
      'access': '神戸電鉄 藍那駅から徒歩すぐ',
      'area': '西神・北神',
      'genre': '自然, 観光',
    },
    {
      'title': '無動寺',
      'description': '紅葉の名所として知られる古刹。境内には西国八十八箇所巡りの仏像があり、静かな時間を過ごせます。',
      'address': '兵庫県神戸市北区山田町福地100',
      'latitude': 34.770913,
      'longitude': 135.137044,
      'imageUrl':
          'assets/images/Mudo-ji_Temple.png',
      'hours': '9:00～17:00',
      'price': '大人 300円',
      'access': '神戸電鉄 箕谷駅から徒歩約25分',
      'area': '西神・北神',
      'genre': '歴史, 自然',
    },
    {
      'title': '淡河宿本陣跡',
      'description': '国の登録有形文化財に指定された、歴史ある本陣跡。現在ではカフェとして利用されており、古民家でゆっくりとくつろげます。',
      'address': '兵庫県神戸市北区淡河町淡河792-1',
      'latitude': 34.856944,
      'longitude': 135.101389,
      'imageUrl':
          'assets/images/Ogo_Shuku_Honjin.png',
      'hours': '11:30～15:30（ランチL.O.14:00）',
      'price': '〜2,000円',
      'access': '道の駅 淡河から徒歩3分',
      'area': '西神・北神',
      'genre': '歴史, グルメ',
    },
    {
      'title': '石峯寺',
      'description': '国重要文化財に指定された仏像や、境内の鐘楼が魅力。紅葉の時期には多くの人が訪れます。',
      'address': '兵庫県神戸市北区淡河町神影110-1',
      'latitude': 34.832539,
      'longitude': 135.137309,
      'imageUrl':
          'assets/images/Shakubuji_Temple.png',
      'hours': '常時開放',
      'price': '無料',
      'access': '神戸電鉄 岡場駅からバス',
      'area': '西神・北神',
      'genre': '歴史, 自然',
    },
    {
      'title': '道の駅「神戸フルーツ・フラワーパーク大沢」',
      'description': '神戸の農産物や土産物が揃う道の駅。四季の花々が咲き誇り、遊園地やホテルも併設されています。',
      'address': '兵庫県神戸市北区大沢町上大沢2150',
      'latitude': 34.848861,
      'longitude': 135.1911154,
      'imageUrl':
          'assets/images/fruit_michinoeki.png',
      'hours': '10:00～20:00（施設により異なる）',
      'price': '無料（一部施設を除く）',
      'access': '六甲北有料道路 大沢IC降りてすぐ',
      'area': '西神・北神',
      'genre': 'グルメ, 観光',
    },
  ];

  // --- 2. 各スポットを 'spots' コレクションに追加し、参照をリストに保存 ---
  final List<DocumentReference> spotRefs = [];
  final spotsCollection = firestore.collection('spots');

  for (final spotData in spotsData) {
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

  // --- 3. 登録するコースの基本情報 ---
  final courseData = {
    'title': '都心部からわずか30分！神戸の「農村・里山」で癒され旅',
    'description': '都会の喧騒を離れ、自然豊かな農村・里山の風景を巡り、心と体を癒すコースです。',
    'imageUrl':
        'assets/images/Ogo_inaka.png',
    'area': '西神・北神',
    'genre': ['自然', '観光', '歴史'],
    'spots': spotRefs,
  };

  // --- 4. コースの情報を 'courses' コレクションに追加 ---
  final existingCourse = await firestore
      .collection('courses')
      .where('title', isEqualTo: courseData['title'])
      .limit(1)
      .get();
  if (existingCourse.docs.isEmpty) {
    await firestore.collection('courses').add(courseData);
    print('✅ コースを追加しました: ${courseData['title']}');
  } else {
    print('ℹ️ 同じ名前のコースが既に存在するため、追加をスキップしました: ${courseData['title']}');
  }

  print('🎉 すべてのデータの登録が完了しました。');
}