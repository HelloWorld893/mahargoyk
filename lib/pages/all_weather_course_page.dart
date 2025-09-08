import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/content_item.dart'; // ContentItem モデルをインポート
import '../widgets/header.dart';
import 'map_page.dart'; // MapPage をインポート

// コース内の各スポットの情報を保持するクラス
class CourseSpot {
  final String title;
  final String description;
  final String address;
  final String transportInfo;
  final String imageUrl;
  final double latitude;
  final double longitude;

  const CourseSpot({
    required this.title,
    required this.description,
    required this.address,
    required this.transportInfo,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });
}

class AllWeatherCoursePage extends StatelessWidget {
  const AllWeatherCoursePage({super.key});

  // コース内のスポットデータを定義
  final List<CourseSpot> _spots = const [
    CourseSpot(
      title: '神戸どうぶつ王国',
      description: '屋内エリアが広く、天気にかかわらず快適にどうぶつたちと触れ合えます。えさやり体験やイベントも充実しています。',
      address: '神戸市中央区港島南町7丁目1-9',
      transportInfo: 'ポートライナー「三宮駅」→「計算科学センター駅」【約15分】',
      imageUrl:
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_kobe_animal_kingdom.jpg',
      latitude: 34.6541,
      longitude: 135.2227,
    ),
    CourseSpot(
      title: 'バンドー神戸青少年科学館',
      description: '科学や宇宙について遊びながら学べるサイエンスミュージアム。体験型の展示やプラネタリウムが楽しめます。',
      address: '神戸市中央区港島中町7丁目7-6',
      transportInfo: 'ポートライナー「計算科学センター駅」→「市民広場駅」【約5分】、徒歩【約10分】',
      imageUrl:
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_kobe_science_museum.jpg',
      latitude: 34.6658,
      longitude: 135.2184,
    ),
    CourseSpot(
      title: 'TOOTH TOOTH MART FOOD HALL & NIGHT FES',
      description: '「神戸ポートミュージアム」の1階にあるフードホール。きらめく水槽を眺めながら、神戸ならではの美味しいランチを。',
      address: '神戸市中央区新港町7-2 神戸ポートミュージアム1F',
      transportInfo: '神姫バス「IKEA神戸」→「新港町」【約15分】',
      imageUrl:
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_tooth_tooth_mart.jpg',
      latitude: 34.6831,
      longitude: 135.1937,
    ),
    CourseSpot(
      title: 'KOBEとんぼ玉ミュージアム',
      description: '国内外のガラス工芸作品が集うミュージアム。好きなガラスの色や模様を選び、とんぼ玉の制作体験ができます。',
      address: '神戸市中央区京町79 日本ビルヂング2F',
      transportInfo: 'フードホールから徒歩【約10分】',
      imageUrl:
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_tonbodama_museum.jpg',
      latitude: 34.6885,
      longitude: 135.1937,
    ),
    CourseSpot(
      title: '神戸海洋博物館',
      description:
          '帆船の帆と波をイメージした白い屋根が特徴。体験型の展示や操船シミュレーターを通して、海・船・港の歴史を楽しく学べます。',
      address: '神戸市中央区波止場町2-2',
      transportInfo: 'シティーループバス「市役所前」→「メリケンパーク」【約5分】、徒歩【約5分】',
      imageUrl:
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_kobe_maritime_museum.jpg',
      latitude: 34.6830,
      longitude: 135.1882,
    ),
    CourseSpot(
      title: '神戸ハーバーランドumie',
      description: '旅の最後は、飲食店やショップが集まる大型商業施設へ。美しい神戸の海を眺めながら食事やお土産選びを楽しめます。',
      address: '神戸市中央区東川崎町1丁目7-2',
      transportInfo: '神戸海洋博物館から徒歩【約15分】',
      imageUrl:
          'https://storage.googleapis.com/mahargoyk-public-assets/spot_kobe_harborland.jpg',
      latitude: 34.6796,
      longitude: 135.1827,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'https://storage.googleapis.com/mahargoyk-public-assets/course_rainy_day_kobe.jpg',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '天気を気にせず楽しめる！神戸の全天候型おでかけコース',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '季節や天気に左右されず、一年中いつでも楽しめる神戸のおでかけコースをご紹介します。体験型の施設を多く取り上げていますので、小さい子ども連れでも、飽ずに楽しめるはず。',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.timer_outlined, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('所要時間: 約7〜8時間', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const Divider(height: 32),
                  ..._spots.map((spot) => _buildSpotCard(context, spot)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 各スポットの情報を表示するカードWidget
  Widget _buildSpotCard(BuildContext context, CourseSpot spot) {
    final spotLocation = LatLng(spot.latitude, spot.longitude);

    // CourseSpotオブジェクトをContentItemオブジェクトに変換する
    final contentItem = ContentItem(
      id: spot.title, // 一意のIDとしてタイトルを使用
      title: spot.title,
      description: spot.description,
      address: spot.address,
      access: spot.transportInfo,
      imageUrl: spot.imageUrl,
      hours: '', // ダミーデータ
      price: '', // ダミーデータ
      latitude: spot.latitude,
      longitude: spot.longitude,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 24.0),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            spot.imageUrl,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spot.transportInfo,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(spot.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  spot.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        spot.address,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 150,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: spotLocation,
                initialZoom: 16.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ), // 操作を無効化
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: spotLocation,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MapPage(initialSpot: contentItem),
                    ),
                  );
                },
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text(
                  'マップで見る',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
