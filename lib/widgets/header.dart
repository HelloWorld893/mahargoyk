// lib/widgets/header.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/login_page.dart';
import '../pages/favorites_page.dart'; // お気に入りページをインポート

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({Key? key}) : super(key: key);

  @override
  _AppHeaderState createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppHeaderState extends State<AppHeader> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    // ログイン状態の変化を監視
    _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('見どころマップ'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.favorite),
              tooltip: 'お気に入り',
              onPressed: () {
                if (_user != null) {
                  // ★★★ ログイン時にお気に入りページへ遷移 ★★★
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FavoritesPage(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('お気に入り機能を使用するにはログインが必要です')),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.language),
              offset: const Offset(0, kToolbarHeight),
              onSelected: (String language) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('言語が $language に変更されました')),
                );
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: '日本語', child: Text('日本語')),
                const PopupMenuItem<String>(value: '英語', child: Text('英語')),
              ],
            ),
            const SizedBox(width: 8),
            if (_user != null) // ログイン済みの場合
              PopupMenuButton<String>(
                offset: const Offset(0, kToolbarHeight),
                icon: const CircleAvatar(
                  radius: 16.0,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                onSelected: (String value) async {
                  if (value == 'logout') {
                    await _auth.signOut();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ログアウトしました')),
                      );
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      _user!.email ?? 'メールアドレスなし',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('ログアウト'),
                      ],
                    ),
                  ),
                ],
              )
            else // 未ログインの場合
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('ログイン'),
              ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
