import 'package:flutter/material.dart';
import 'navbar.dart';
import '../../core/constants/app_colors.dart';

// This file is just for previewing the navbar
// Run with: flutter run lib/shared/widgets/navbar_preview.dart

void main() {
  runApp(const MaterialApp(
    home: NavBarPreview(),
    debugShowCheckedModeBanner: false,
  ));
}

class NavBarPreview extends StatefulWidget {
  const NavBarPreview({super.key});

  @override
  State<NavBarPreview> createState() => _NavBarPreviewState();
}

class _NavBarPreviewState extends State<NavBarPreview> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NavBar Component Test'),
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Testing CustomNavBar',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Currently Selected:',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _getSelectedPage(),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  String _getSelectedPage() {
    switch (_currentIndex) {
      case 0: return '🏠 Home';
      case 1: return '💬 Chat';
      case 2: return '❤️ Favourite';
      case 3: return '📚 Shelves';
      default: return '';
    }
  }
}