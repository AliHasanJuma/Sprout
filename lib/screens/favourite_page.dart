import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Added Auth
import '../data/temp_data.dart';
import 'store_page.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => FavouritePageState();
}

class FavouritePageState extends State<FavouritePage> {
  // We no longer need the local refresh() because StreamBuilder handles it automatically!

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // ── STEP 1: Listen to User's ID list ──
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF003E3B)));
            }

            final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
            final List<dynamic> favIds = userData['favouriteStoreIds'] ?? [];

            // If the array is empty (or doesn't exist yet)
            if (favIds.isEmpty) {
              return _buildEmptyState();
            }

            // ── STEP 2: Fetch Store details for those IDs ──
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('stores')
                  .where(FieldPath.documentId, whereIn: favIds)
                  .get(),
              builder: (context, storeSnapshot) {
                if (storeSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF003E3B)));
                }
                
                final stores = storeSnapshot.data?.docs ?? [];

                // Fallback just in case IDs exist but the store documents were deleted
                if (stores.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: stores.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  itemBuilder: (context, index) {
                    final data = stores[index].data() as Map<String, dynamic>;
                    final storeId = stores[index].id;
                    return _buildFavRow(context, data, storeId, uid!);
                  },
                );
              },
            );
          },
        ),
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

  Widget _buildFavRow(BuildContext context, Map<String, dynamic> data, String storeId, String uid) {
    // Map Firebase data to your Store model so StorePage works correctly
    final store = Store(
      id: storeId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imagePath: data['imageUrl'] ?? '',
      logoPath: data['logoUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      category: data['category'] ?? 'General',
      distanceKm: (data['distanceKm'] ?? 0.0).toDouble(),
      products: [], // Will be loaded dynamically in StorePage
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StorePage(store: store)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Store image (Using Network Image for Firebase)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
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
            const SizedBox(width: 16),
            // Store info
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
                  const SizedBox(height: 6),
                  _buildStars(store.rating),
                ],
              ),
            ),
            // Remove heart button (Updates Firebase)
            IconButton(
              icon: const Icon(Icons.favorite, color: Color(0xFF003E3B), size: 24),
              onPressed: () async {
                // Remove the store ID from the user's array
                await FirebaseFirestore.instance.collection('users').doc(uid).update({
                  'favouriteStoreIds': FieldValue.arrayRemove([storeId])
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