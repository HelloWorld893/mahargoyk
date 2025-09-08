import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_item.dart';
import 'course_detail_page.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/header.dart';
import 'all_weather_course_page.dart'; // 作成したページをインポート

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
    debugPrint('データの読み込み中にエラーが発生しました: $e');
    return [];
  }
}

class CourseListPage extends StatefulWidget {
  final String title;
  final String collectionName;

  const CourseListPage({
    super.key,
    required this.title,
    required this.collectionName,
  });

  @override
  CourseListPageState createState() => CourseListPageState();
}

class CourseListPageState extends State<CourseListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final int _selectedIndex = 4;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Firebaseから取得したコースのカード
  Widget _buildImageCard(BuildContext context, ContentItem item) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CourseDetailPage(course: item),
          ),
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

  // 特集コース（全天候型コース）のカード
  Widget _buildFeaturedCourseCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AllWeatherCoursePage()),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'https://storage.googleapis.com/mahargoyk-public-assets/course_rainy_day_kobe.jpg',
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '天気を気にせず楽しめる！神戸の全天候型おでかけコース',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text('雨の日でも安心の屋内施設を中心に巡る特集コースです。'),
                ],
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
      body: Padding(
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFeaturedCourseCard(context),
                    const Divider(height: 24),
                    FutureBuilder<List<ContentItem>>(
                      future: _fetchFromCollection(widget.collectionName),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'データの読み込み中にエラーが発生しました: ${snapshot.error}',
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('データが見つかりませんでした。'));
                        } else {
                          final items = snapshot.data!
                              .where(
                                (item) =>
                                    item.title.contains(_searchText) ||
                                    item.description.contains(_searchText),
                              )
                              .toList();

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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(currentIndex: _selectedIndex),
    );
  }
}
