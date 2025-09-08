// lib/pages/content_list_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_item.dart';
import 'spot_detail_page.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/header.dart';

// 各コレクションからデータを取得する共通関数
Future<List<ContentItem>> _fetchFromCollection(String collectionName) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .get();

    return querySnapshot.docs
        .map((doc) => ContentItem.fromFirestore(doc))
        .toList();
  } catch (e) {
    // 本来はロギングフレームワークを使用することが推奨されます
    debugPrint('データの読み込み中にエラーが発生しました: $e');
    return [];
  }
}

class ContentListPage extends StatefulWidget {
  final String title;
  final String collectionName;

  const ContentListPage({
    super.key, // use_super_parameters の修正
    required this.title,
    required this.collectionName,
  });

  @override
  // library_private_types_in_public_api の修正
  ContentListPageState createState() => ContentListPageState();
}

// library_private_types_in_public_api の修正
class ContentListPageState extends State<ContentListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
    // 現在のページに基づいてcurrentIndexを設定
    if (widget.collectionName == 'spots') {
      _selectedIndex = 1;
    } else if (widget.collectionName == 'events') {
      _selectedIndex = 3;
    } else if (widget.collectionName == 'courses') {
      _selectedIndex = 4;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: FutureBuilder<List<ContentItem>>(
        future: _fetchFromCollection(widget.collectionName),
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
            final items = snapshot.data!
                .where(
                  (item) =>
                      item.title.contains(_searchText) ||
                      item.description.contains(_searchText),
                )
                .toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'キーワードで検索',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: items.map((item) {
                        return _buildImageCard(context, item);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: AppBottomNavigation(currentIndex: _selectedIndex),
    );
  }
}
