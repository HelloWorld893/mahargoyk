// lib/widgets/bottom_navigation.dart
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/content_list_page.dart';
import '../pages/map_page.dart';
import '../pages/course_list_page.dart'; // course_list_page.dart をインポート

class BottomNavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomNavigationItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: isSelected ? Colors.amber[800] : Colors.black),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.amber[800] : Colors.black,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class AppBottomNavigation extends StatefulWidget {
  final int currentIndex;

  const AppBottomNavigation({Key? key, required this.currentIndex})
    : super(key: key);

  @override
  _AppBottomNavigationState createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends State<AppBottomNavigation> {
  void _onItemTapped(int index) {
    if (widget.currentIndex == index) return;

    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              const ContentListPage(title: 'スポット', collectionName: 'spots'),
        ),
      );
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MapPage()),
      );
    } else if (index == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              const ContentListPage(title: 'イベント', collectionName: 'events'),
        ),
      );
    } else if (index == 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              const CourseListPage(title: 'モデルコース', collectionName: 'courses'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          BottomNavigationItem(
            icon: Icons.home,
            label: 'ホーム',
            isSelected: widget.currentIndex == 0,
            onTap: () => _onItemTapped(0),
          ),
          BottomNavigationItem(
            icon: Icons.attractions,
            label: 'スポット',
            isSelected: widget.currentIndex == 1,
            onTap: () => _onItemTapped(1),
          ),
          BottomNavigationItem(
            icon: Icons.location_on,
            label: 'マップ',
            isSelected: widget.currentIndex == 2,
            onTap: () => _onItemTapped(2),
          ),
          BottomNavigationItem(
            icon: Icons.event,
            label: 'イベント',
            isSelected: widget.currentIndex == 3,
            onTap: () => _onItemTapped(3),
          ),
          BottomNavigationItem(
            icon: Icons.map,
            label: 'モデルコース',
            isSelected: widget.currentIndex == 4,
            onTap: () => _onItemTapped(4),
          ),
        ],
      ),
    );
  }
}
