import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/UI icons package/PNG/Black/Arrow/Arrow_Left_MD.png', width: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Category', style: TextStyle(color: Colors.black)),
      ),
      body: const Center(child: Text('Category Page - Coming Soon')),
    );
  }
}
