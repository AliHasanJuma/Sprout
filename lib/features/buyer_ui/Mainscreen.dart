// lib/features/home/main_screen.dart
import 'package:flutter/material.dart';
import '../../shared/widgets/navbar.dart';
import 'home_page.dart';
import '../../screens/chats_page.dart';
import '../../screens/favourite_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Since Firebase handles real-time updates, we don't need Keys anymore!
  final List<Widget> _pages = const [
    HomePage(),
    ChatsPage(),
    FavouritePage(),
    Center(child: Text('Shelves Page')), // To be built later
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
          // The old manual refresh logic was deleted here
        },
      ),
    );
  }
}