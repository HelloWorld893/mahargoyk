// lib/widgets/bottom_navigation.dart

import 'package:flutter/material.dart';
import '../pages/home_page.dart';
// ★★★ どのファイルからどのクラスをインポートするかを明確にする ★★★
import '../pages/content_list_page.dart'; // ContentListPage をここから読み込む
import '../pages/course_list_page.dart'; // CourseListPage をここから読み込む
import '../pages/event_list_page.dart';
import '../pages/map_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AppBottomNavigation extends StatefulWidget {
  final int currentIndex;

  const AppBottomNavigation({super.key, required this.currentIndex});

  @override
  AppBottomNavigationState createState() => AppBottomNavigationState();
}

class AppBottomNavigationState extends State<AppBottomNavigation> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) async {
    if (index == _selectedIndex) return;

if (index != 4 && index != 5) {
    setState(() {
      _selectedIndex = index;
    });
  }
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const HomePage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const ContentListPage(title: 'スポット一覧', collectionName: 'spots'),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const CourseListPage(), // CourseListPageを正しく呼び出す
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const EventListPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 4:
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const MapPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
case 5: // チケット
  const url = 'https://app.surutto-qrtto.com/tabs/home';
  final uri = Uri.parse(url);

  final shouldLaunch = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('外部サイトへ移動'),
        content: const Text('https://app.surutto-qrtto.com/（外部サイト）を開きます。よろしいですか？'),
        actions: <Widget>[
          TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );

  if (shouldLaunch == true) {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URLを開けませんでした')),
      );
    }
  }

  break;

    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
        BottomNavigationBarItem(icon: Icon(Icons.place), label: 'スポット'),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_walk),
          label: 'モデルコース',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'イベント'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'マップ'),
        BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: 'チケット'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    );
  }
}
