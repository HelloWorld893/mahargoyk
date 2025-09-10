// tool/upload_kitano_course.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahargoyk/firebase_options.dart';

Future<void> main() async {
  // --- Firebaseの初期化 ---
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;
  print('Firebaseの初期化が完了しました。北野異人館街コースの登録を開始します...');

  // --- 1. コースに含まれるスポットのリスト ---
  // 先に各スポットの情報を定義します
  final spotsData = [
    {
      'title': '神戸トリックアート不思議な領事館',
      'description':
          '明治後期に建築されパナマ領事館として使用されていた館。ヨーロッパで生まれたトリックアートが展示されており、神戸らしい作品も楽しめます。',
      'address': '神戸市中央区北野町2-10-7',
      'latitude': 34.700882,
      'longitude': 135.190862,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_kobe_trick_art.jpg',
      'hours': '10:00～17:00',
      'price': '大人 880円',
      'access': 'シティーループバス「北野異人館」下車すぐ',
      'area': '北野・新神戸',
      'genre': '体験',
    },
    {
      'title': '英国館',
      'description':
          '明治42年築のコロニアル様式の洋館。2階にはシャーロック・ホームズの部屋が再現され、マントと帽子で記念撮影ができます。',
      'address': '神戸市中央区北野町2-3-16',
      'latitude': 34.700738,
      'longitude': 135.191172,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_british_house.jpg',
      'hours': '10:00～17:00',
      'price': '大人 880円',
      'access': 'シティーループバス「北野異人館」下車すぐ',
      'area': '北野・新神戸',
      'genre': '歴史',
    },
    {
      'title': '北野外国人倶楽部',
      'description':
          '明治後期築の木造2階建ての館。重厚な家具や暖炉で当時の華やかな暮らしを再現。1日4組限定のドレス撮影体験も人気です（要予約）。',
      'address': '神戸市中央区北野町2-18-2',
      'latitude': 34.703078,
      'longitude': 135.191351,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_kitano_foreigners_club.jpg',
      'hours': '10:00～17:00',
      'price': '大人 550円',
      'access': 'シティーループバス「北野異人館」から徒歩8分',
      'area': '北野・新神戸',
      'genre': '体験',
    },
    {
      'title': '香りの家オランダ館',
      'description': '旧オランダ王国総領事邸。花の国オランダにちなみ、オリジナルの香水作り体験ができます。民族衣装での記念撮影も人気。',
      'address': '神戸市中央区北野町2-15-10',
      'latitude': 34.702188,
      'longitude': 135.190648,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_netherlands_museum.jpg',
      'hours': '10:00～17:00',
      'price': '大人 700円',
      'access': 'シティーループバス「北野異人館」から徒歩5分',
      'area': '北野・新神戸',
      'genre': '体験',
    },
    {
      'title': '風見鶏の館',
      'description': 'レンガの外壁と尖塔の風見鶏がシンボルの、国指定重要文化財。北野異人館の象徴的存在として愛されています。',
      'address': '神戸市中央区北野町3-13-3',
      'latitude': 34.70119,
      'longitude': 135.1906,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_weathercock_house.jpg',
      'hours': '9:00～18:00',
      'price': '大人 500円',
      'access': '各線三宮駅から徒歩約15分',
      'area': '北野・新神戸',
      'genre': '歴史',
    },
    {
      'title': '萌黄の館',
      'description': '淡いグリーンの外壁が特徴的な国指定重要文化財の異人館。2階のサンルームからは神戸の美しい街並みが楽しめます。',
      'address': '神戸市中央区北野町3-10-11',
      'latitude': 34.700977,
      'longitude': 135.189255,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_moegi_house.jpg',
      'hours': '9:30～18:00',
      'price': '大人 400円',
      'access': '各線三宮駅から徒歩約15分',
      'area': '北野・新神戸',
      'genre': '歴史',
    },
    {
      'title': '神戸北野ノスタ',
      'description':
          '旧北野小学校をリノベーションした複合施設。レストラン、カフェ、スイーツ店などがあり、食事や休憩、お土産探しに最適です。',
      'address': '神戸市中央区中山手通3丁目17-1',
      'latitude': 34.695531,
      'longitude': 135.187026,
      'imageUrl':
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_kitano_nosta.jpg',
      'hours': '店舗による',
      'price': '無料（施設内店舗は有料）',
      'access': '北野町広場から徒歩10分',
      'area': '北野・新神戸',
      'genre': 'グルメ',
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

  // --- 3. 登録するコースの基本情報 ---
  final courseData = {
    'title': '神戸北野異人館街で異文化体験！大満足の半日観光コース',
    'description': '神戸の開港後に栄えた異国情緒あふれるエリアで、トリックアートやドレス体験、香水作りなど、思い出に残る体験ができます。',
    'imageUrl':
        'https://storage.googleapis.com/mahargoyk-public-assets/course_kobe_kitano.jpg',
    'area': '北野・新神戸',
    'genre': ['観光', '歴史', '体験'],
    'spots': spotRefs,
  };

  // --- 4. コースの情報を 'courses' コレクションに追加 ---
  // 同じタイトルのコースが既に存在するか確認
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
