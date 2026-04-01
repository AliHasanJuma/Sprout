import 'package:flutter/material.dart';
import '../../../data/temp_data.dart';
import '../../../screens/store_page.dart';

class NewStoresPage extends StatelessWidget {
  const NewStoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    // In temp data all stores are "new" — in production, filter by createdAt
    final stores = tempStores.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003E3B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Stores',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: stores.length,
        itemBuilder: (context, index) =>
            _buildStoreCard(context, stores[index]),
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context, Store store) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StorePage(store: store)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                store.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCDEB45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.description,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 12,
                      color: Color(0xFF9F9F9F),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
