import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../data/temp_data.dart';
import '../../screens/store_page.dart';

/// Reusable category page that filters stores by category name directly from Firebase.
class CategoryStoresPage extends StatelessWidget {
  final String categoryName;

  const CategoryStoresPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Clean up the category name for the header title display
    final cleanCategoryQuery = categoryName.replaceAll('\n', ' ');

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
          cleanCategoryQuery,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('stores').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF003E3B)));
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading stores', style: TextStyle(color: Color(0xFF9F9F9F))),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          final storesDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String dbCategory = (data['category'] ?? '').toString();
            
            final String targetLower = categoryName.toLowerCase();
            final String dbLower = dbCategory.toLowerCase();

            // ── UNIVERSAL NORMALIZATION ──
            final targetNormalized = targetLower.replaceAll(RegExp(r'[\s\n]+'), '').replaceAll('&', 'and');
            final dbNormalized = dbLower.replaceAll(RegExp(r'[\s\n]+'), '').replaceAll('&', 'and');
            
            if (dbNormalized == targetNormalized) return true;

            // ── FALLBACK 1: SWEETS & BAKING KEYWORD MATCH ──
            if (targetLower.contains('sweet') && targetLower.contains('bak') &&
                dbLower.contains('sweet') && dbLower.contains('bak')) {
              return true;
            }

            // ── FALLBACK 2: CRAFTS & HOME DECOR KEYWORD MATCH ──
            if (targetLower.contains('craft') && targetLower.contains('decor') &&
                dbLower.contains('craft') && dbLower.contains('decor')) {
              return true;
            }

            return dbNormalized == targetNormalized;
          }).toList();

          if (storesDocs.isEmpty) {
            return const Center(
              child: Text(
                'No stores found in this category',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  color: Color(0xFF9F9F9F),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: storesDocs.length,
            itemBuilder: (context, index) {
              final data = storesDocs[index].data() as Map<String, dynamic>;
              final storeId = storesDocs[index].id;
              return _buildStoreCardFromFirebase(context, data, storeId);
            },
          );
        },
      ),
    );
  }

  Widget _buildStoreCardFromFirebase(BuildContext context, Map<String, dynamic> data, String docId) {
    final String storeDescription = data['bio'] ?? data['description'] ?? '';
    final String storeBanner = data['bannerPath'] ?? data['imageUrl'] ?? '';
    final String storeLogo = data['logoPath'] ?? data['logoUrl'] ?? '';
    final double storeDistance = (data['distanceKm'] ?? 0.0).toDouble();

    final store = Store(
      id: docId,
      name: data['name'] ?? 'Shop',
      description: storeDescription,
      imagePath: storeBanner.isNotEmpty ? storeBanner : 'https://via.placeholder.com/80',
      logoPath: storeLogo.isNotEmpty ? storeLogo : 'https://via.placeholder.com/80',
      rating: (data['rating'] ?? 0.0).toDouble(),
      category: data['category'] ?? 'General',
      distanceKm: storeDistance,
      products: [], 
    );

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
              // ── FIXED: Swapped out store.imagePath for store.logoPath ──
              child: store.logoPath.startsWith('http')
                  ? Image.network(
                      store.logoPath,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
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

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(12),
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