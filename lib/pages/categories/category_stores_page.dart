import 'package:flutter/material.dart';
import '../../data/temp_data.dart';
import '../../screens/store_page.dart';

/// Reusable category page that filters stores by category name.
class CategoryStoresPage extends StatelessWidget {
  final String categoryName;

  const CategoryStoresPage({super.key, required this.categoryName});

  List<Store> get _filteredStores {
    final q = categoryName.toLowerCase().replaceAll('\n', ' ');
    return tempStores.where((s) {
      final cat = s.category.toLowerCase().replaceAll('\n', ' ');
      return cat.contains(q) || q.contains(cat);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final stores = _filteredStores;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003E3B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName.replaceAll('\n', ' '),
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: stores.isEmpty
          ? const Center(
              child: Text(
                'No stores found in this category',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  color: Color(0xFF9F9F9F),
                ),
              ),
            )
          : ListView.builder(
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildStars(store.rating),
                      const SizedBox(width: 8),
                      Text(
                        '${store.distanceKm.toStringAsFixed(0)} km',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 12,
                          color: Color(0xFF9F9F9F),
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

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final full = i < rating.floor();
        final half = !full && (rating - i) >= 0.5 && (rating - i) < 1.0;
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
    );
  }
}
