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

  // Keys to access page state for refresh
  final GlobalKey<FavouritePageState> _favKey = GlobalKey<FavouritePageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const ChatsPage(),
      FavouritePage(key: _favKey),
      const Center(child: Text('Shelves Page')), // To be built later
    ];
  }

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
          // Refresh favourites when switching to that tab
          if (index == 2) {
            _favKey.currentState?.refresh();
          }
        },
      ),
    );
  }
}