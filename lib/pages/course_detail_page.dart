// lib/pages/course_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/course_item.dart';
import '../models/content_item.dart';
import '../services/firestore_service.dart';
import '../widgets/header.dart';
import 'map_page.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;

  const CourseDetailPage({super.key, required this.courseId});

  @override
  CourseDetailPageState createState() => CourseDetailPageState();
}

class CourseDetailPageState extends State<CourseDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  Future<CourseItem>? _courseFuture;

  @override
  void initState() {
    super.initState();
    _courseFuture = _firestoreService.getCourseWithSpots(widget.courseId);
  }

  // ★★★ 新しく追加：スポット間のアクセス情報を表示するWidget ★★★
  Widget _buildTransportLink(String accessInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左側の点線
          Column(
            children: List.generate(
              10,
              (index) => Container(
                width: 2,
                height: 4,
                margin: const EdgeInsets.only(bottom: 2),
                color: Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // アイコンとアクセス情報
          const Icon(Icons.directions_walk, color: Colors.blueAccent),
          const SizedBox(width: 8),
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

  // 各スポットの情報を表示するカードWidget（変更なし）
  Widget _buildSpotCard(BuildContext context, ContentItem spot) {
    final spotLocation = LatLng(spot.latitude, spot.longitude);

    return Card(
      margin: const EdgeInsets.all(0), // マージンをリセット
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 680,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(spot.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),
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
          SizedBox(
            height: 150,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: spotLocation,
                initialZoom: 16.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
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
                      builder: (context) => MapPage(initialSpot: spot),
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

  // ★★★ buildメソッド内のスポットリスト表示部分を修正 ★★★
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
                Center(
                  child: SizedBox(
                    width: 680,
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(course.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                ),
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

                      // スポットリストを動的に生成
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: course.spots.length,
                        itemBuilder: (context, index) {
                          final spot = course.spots[index];
                          // 最初のスポット以外は、カードの前にアクセス情報を表示
                          if (index > 0) {
                            return Column(
                              children: [
                                _buildTransportLink(spot.access),
                                _buildSpotCard(context, spot),
                              ],
                            );
                          }
                          // 最初のスポットはカードのみ表示
                          return _buildSpotCard(context, spot);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
