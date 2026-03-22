import 'package:flutter/material.dart';

class StorePage extends StatelessWidget {
  final String storeName;

  const StorePage({super.key, required this.storeName});

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
        title: Text(storeName, style: const TextStyle(color: Colors.black)),
      ),
      body: const Center(child: Text('Store Page - Coming Soon')),
    );
  }
}
