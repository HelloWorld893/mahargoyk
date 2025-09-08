// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/header.dart';
import '../widgets/bottom_navigation.dart';
import '../models/content_item.dart';
import 'spot_detail_page.dart';
import 'content_list_page.dart';

// 各コレクションからデータを取得する共通関数
Future<List<ContentItem>> _fetchFromCollection(String collectionName) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .limit(3) // <-- ここで表示件数を3件に制限します
        .get();

    return querySnapshot.docs
        .map((doc) => ContentItem.fromFirestore(doc))
        .toList();
  } catch (e) {
    // avoid_print の修正
    debugPrint('データの読み込み中にエラーが発生しました: $e');
    return [];
  }
}

class HomePage extends StatefulWidget {
  // use_super_parameters の修正
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // prefer_final_fields の修正
  final int _selectedIndex = 0;

  Widget _buildImageCard(BuildContext context, ContentItem item) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SpotDetailPage(spot: item)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(item.imageUrl, fit: BoxFit.cover),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(String title, String collectionName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ContentListPage(
                      title: title,
                      collectionName: collectionName,
                    ),
                  ),
                );
              },
              child: const Text('もっと見る'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<ContentItem>>(
          future: _fetchFromCollection(collectionName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('データの読み込み中にエラーが発生しました: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('データが見つかりませんでした。'));
            } else {
              final items = snapshot.data!;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: items.map((item) {
                  return _buildImageCard(context, item);
                }).toList(),
              );
            }
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 検索バー
              TextField(
                decoration: InputDecoration(
                  hintText: '行き先やキーワードで検索',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 24),

              // 統一された関数で各セクションを構築
              _buildContentSection('スポット', 'spots'),
              _buildContentSection('イベント', 'events'),
              _buildContentSection('モデルコース', 'courses'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(currentIndex: _selectedIndex),
    );
  }
}
