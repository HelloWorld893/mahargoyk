// lib/pages/event_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mahargoyk/models/content_item.dart';
import 'package:mahargoyk/widgets/bottom_navigation.dart';
import 'package:mahargoyk/widgets/header.dart';
import 'map_page.dart';

class EventDetailPage extends StatelessWidget {
  final ContentItem event;

  const EventDetailPage({super.key, required this.event});

  void _navigateToMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MapPage(initialSpot: event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime? date) {
      if (date == null) return '未定';
      return DateFormat('yyyy年M月d日').format(date);
    }

    final startDate = event.startDate?.toDate();
    final endDate = event.endDate?.toDate();
    final eventLocation = LatLng(event.latitude, event.longitude);

    String periodText;
    if (startDate != null && endDate != null) {
      if (startDate.isAtSameMomentAs(endDate)) {
        periodText = formatDate(startDate);
      } else {
        periodText = '${formatDate(startDate)} ～ ${formatDate(endDate)}';
      }
    } else {
      periodText = '開催期間未定';
    }

    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // メイン画像
                if (event.imageUrl.isNotEmpty)
                  // ★★★ AspectRatioとAlignを追加して画像を中央揃え4:3に ★★★
                  Align(
                    alignment: Alignment.center,
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        event.imageUrl,
                        width: double.infinity,
                        height: 250, // AspectRatioがあるのでheightは実質無効になります
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // イベントタイトル
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      // イベント基本情報セクション
                      _buildInfoSection(
                        context,
                        icon: Icons.calendar_today,
                        title: '開催期間',
                        content: periodText,
                      ),
                      _buildInfoSection(
                        context,
                        icon: Icons.access_time,
                        title: '開催時間',
                        content: event.hours,
                      ),
                      _buildInfoSection(
                        context,
                        icon: Icons.local_attraction,
                        title: '料金',
                        content: event.price,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // イベント説明
                      Text(
                        'イベント詳細',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // アクセス情報
                      Text(
                        'アクセス',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        context,
                        icon: Icons.location_on,
                        title: '住所',
                        content: event.address,
                      ),
                      _buildInfoSection(
                        context,
                        icon: Icons.train,
                        title: 'アクセス',
                        content: event.access,
                      ),

                      const SizedBox(height: 24),
                      Text(
                        '開催場所',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: eventLocation,
                            initialZoom: 16.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: eventLocation,
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
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToMap(context),
                          icon: const Icon(Icons.map),
                          label: const Text('マップで見る'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 2),
                Text(content, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
