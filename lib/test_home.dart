import 'package:flutter/material.dart';
import 'features/buyer_ui/home_page.dart';
import 'shared/widgets/navbar.dart';
import 'core/constants/app_colors.dart';

void main() {
  runApp(const MaterialApp(
    home: MainScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('Chat Page')),
    const Center(child: Text('Favourites Page')),
    const Center(child: Text('Shelves Page')),
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