// lib/features/home/main_screen.dart
import 'package:flutter/material.dart';
import '../../shared/widgets/navbar.dart';
import 'home_page.dart';
import '../../screens/chats_page.dart';
import '../../screens/favourite_page.dart';
import '../seller/shelves_tab.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex = widget.initialIndex;

  final List<Widget> _pages = const [
    HomePage(),
    ChatsPage(),
    FavouritePage(),
    ShelvesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}