import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahargoyk/models/content_item.dart';
import 'package:mahargoyk/widgets/bottom_navigation.dart';
import 'package:mahargoyk/widgets/header.dart';

class EventDetailPage extends StatelessWidget {
  final ContentItem event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // 日付を 'yyyy年M月d日' の形式に変換するヘルパー関数
    String formatDate(DateTime? date) {
      if (date == null) return '未定';
      return DateFormat('yyyy年M月d日').format(date);
    }

    final startDate = event.startDate?.toDate();
    final endDate = event.endDate?.toDate();

    String periodText;
    if (startDate != null && endDate != null) {
      if (startDate.isAtSameMomentAs(endDate)) {
        periodText = formatDate(startDate); // 開始日と終了日が同じなら1日だけ表示
      } else {
        periodText = '${formatDate(startDate)} ～ ${formatDate(endDate)}';
      }
    } else {
      periodText = '開催期間未定';
    }

    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // メイン画像
            if (event.imageUrl.isNotEmpty)
              Image.network(
                event.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // イベントタイトル
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                  Text('イベント詳細', style: Theme.of(context).textTheme.titleLarge),
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
                  Text('アクセス', style: Theme.of(context).textTheme.titleLarge),
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
                ],
              ),
            ),
          ],
        ),
      ),
      // ★★★ この行でボトムナビゲーションバーを正しく表示します ★★★
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }

  // 情報セクションを作成するヘルパーWidget
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
