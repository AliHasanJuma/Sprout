import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

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
        title: const Text('Search', style: TextStyle(color: Colors.black)),
      ),
      body: const Center(
        child: Text('Search functionality coming soon'),
      ),
    );
  }
}