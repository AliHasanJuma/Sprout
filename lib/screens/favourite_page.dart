// TODO: Replace with Firebase
import 'package:flutter/material.dart';
import '../data/temp_data.dart';
import 'store_page.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => FavouritePageState();
}

class FavouritePageState extends State<FavouritePage> {
  /// Call this from parent to refresh the list when returning from StorePage
  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: tempFavourites.isEmpty ? _buildEmptyState() : _buildFilledState(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heart + sad face illustration
            Image.asset(
              'assets/icons/MG_favourite_list.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.favorite_border,
                size: 120,
                color: Color(0xFF003E3B),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Empty favourite list',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003E3B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can add and modify your favourite\nproducts in this page',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 14,
                color: Color(0xFF9F9F9F),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilledState() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: tempFavourites.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) {
        final fav = tempFavourites[index];
        return _buildFavRow(fav);
      },
    );
  }

  Widget _buildFavRow(FavouriteItem fav) {
    // Find the full store object
    final store = tempStores.firstWhere(
      (s) => s.id == fav.storeId,
      orElse: () => tempStores.first,
    );

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StorePage(store: store)),
        );
        // Refresh after returning (favourite might have been toggled)
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Store image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                fav.imagePath,
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
            const SizedBox(width: 16),
            // Store info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fav.storeName,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildStars(fav.rating),
                ],
              ),
            ),
            // Remove heart button
            IconButton(
              icon: const Icon(Icons.favorite,
                  color: Color(0xFF003E3B), size: 24),
              onPressed: () {
                setState(() {
                  tempFavourites.removeWhere((f) => f.storeId == fav.storeId);
                });
              },
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
