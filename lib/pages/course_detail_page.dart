// lib/pages/course_detail_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_item.dart';
import '../models/content_item.dart';
import 'spot_detail_page.dart';
import '../widgets/header.dart';
import '../widgets/bottom_navigation.dart';

class CourseDetailPage extends StatefulWidget {
  // ★★★ courseIdからCourseItemオブジェクト全体を受け取るように変更 ★★★
  final CourseItem course;

  const CourseDetailPage({super.key, required this.course});

  @override
  CourseDetailPageState createState() => CourseDetailPageState();
}

class CourseDetailPageState extends State<CourseDetailPage> {
  late Future<List<ContentItem>> _spotDetailsFuture;

  @override
  void initState() {
    super.initState();
    _spotDetailsFuture = _fetchSpotDetails(widget.course.spotRefs);
  }

  Future<List<ContentItem>> _fetchSpotDetails(
    List<DocumentReference> spotRefs,
  ) async {
    final List<ContentItem> spotDetails = [];
    for (var spotRef in spotRefs) {
      final spotDoc = await spotRef.get();
      if (spotDoc.exists) {
        spotDetails.add(ContentItem.fromFirestore(spotDoc));
      }
    }
    return spotDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              widget.course.imageUrl,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.course.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'コースに含まれるスポット',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            FutureBuilder<List<ContentItem>>(
              future: _spotDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('エラー: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('スポット情報が見つかりません。'));
                }

                final spots = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: spots.length,
                  itemBuilder: (context, index) {
                    final spot = spots[index];
                    return ListTile(
                      leading: Image.network(
                        spot.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                      title: Text(spot.title),
                      subtitle: Text(
                        spot.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SpotDetailPage(spot: spot),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }
}
