import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/course_item.dart';
import '../models/content_item.dart';
import '../services/firestore_service.dart';
import '../widgets/header.dart';
import '../widgets/bottom_navigation.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;

  const CourseDetailPage({super.key, required this.courseId});

  @override
  CourseDetailPageState createState() => CourseDetailPageState();
}

class CourseDetailPageState extends State<CourseDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<CourseItem> _courseFuture;

  @override
  void initState() {
    super.initState();
    _courseFuture = _firestoreService.getCourseWithSpots(widget.courseId);
  }

  // Googleマップアプリでスポットを開く
  void _launchGoogleMaps(ContentItem spot) async {
    final url =
        'https://googleusercontent.com/maps/search/?api=1&query=${spot.latitude},${spot.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('マップアプリを開けませんでした。')));
    }
  }

  // スポット間の移動案内を表示するWidget
  Widget _buildTransportLink(String accessInfo) {
    // accessInfoが空の場合は何も表示しない
    if (accessInfo.trim().isEmpty) {
      accessInfo = "次のスポットへ"; // デフォルトテキスト
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 24.0,
        horizontal: 70.0,
      ), // 横の余白を調整
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 中央寄せ
        children: [
          const Icon(Icons.directions_walk, color: Colors.blueAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              accessInfo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 各スポットの情報を表示するカードWidget
  Widget _buildSpotCard(BuildContext context, ContentItem spot) {
    final spotLocation = LatLng(spot.latitude, spot.longitude);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4:3比率の画像
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(spot.imageUrl, fit: BoxFit.cover),
          ),
          // スポット名、説明、住所
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          // ミニマップ
          SizedBox(
            height: 150,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: spotLocation,
                initialZoom: 16.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ), // 操作不可
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
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
          // マップで開くボタン
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchGoogleMaps(spot),
                icon: const Icon(Icons.map),
                label: const Text('マップで開く'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: FutureBuilder<CourseItem>(
        future: _courseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('コースが見つかりません。'));
          }

          final course = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // コースのメイン画像
                Image.network(
                  course.imageUrl,
                  fit: BoxFit.cover,
                  height: 250,
                  width: double.infinity,
                ),
                // コースのタイトルと説明
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Divider(height: 32),
                    ],
                  ),
                ),
                // スポットリストを動的に生成
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: course.spots.length,
                  itemBuilder: (context, index) {
                    final spot = course.spots[index];
                    return Column(
                      children: [
                        // 最初のスポット以外は、カードの前にアクセス情報を表示
                        if (index > 0) _buildTransportLink(spot.access),

                        _buildSpotCard(context, spot),

                        // 最後のスポットの場合は下に余白を追加
                        if (index == course.spots.length - 1)
                          const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }
}
