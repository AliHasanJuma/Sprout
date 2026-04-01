import 'package:flutter/material.dart';
import '../../../data/temp_data.dart';
import '../../../screens/store_page.dart';

class TopRatedPage extends StatelessWidget {
  const TopRatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stores = List<Store>.from(tempStores)
      ..sort((a, b) => b.rating.compareTo(a.rating));

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
          'Top Rated',
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
            _buildStoreCard(context, stores[index], index + 1),
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context, Store store, int rank) {
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
            // Rank number
            SizedBox(
              width: 28,
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003E3B),
                ),
              ),
            ),
            const SizedBox(width: 8),
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
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.description,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 12,
                      color: Color(0xFF9F9F9F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        final full = i < store.rating.floor();
                        final half = !full &&
                            (store.rating - i) >= 0.5 &&
                            (store.rating - i) < 1.0;
                        return Icon(
                          full
                              ? Icons.star
                              : half
                                  ? Icons.star_half
                                  : Icons.star_border,
                          size: 13,
                          color: Colors.amber,
                        );
                      }),
                      const SizedBox(width: 6),
                      Text(
                        store.rating.toString(),
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
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
