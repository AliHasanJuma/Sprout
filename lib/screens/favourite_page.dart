import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import '../data/temp_data.dart';
import 'store_page.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => FavouritePageState();
}

// ── 1. ADD THE MIXIN ──
class FavouritePageState extends State<FavouritePage> with AutomaticKeepAliveClientMixin {
  
  // ── 2. LOCK THE PAGE IN MEMORY ──
  @override
  bool get wantKeepAlive => true; 

  bool _isLoading = true;
  List<QueryDocumentSnapshot> _favouriteStores = [];
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _loadFavourites(); // Fetch data once when the tab is first opened
  }

  // ── 3. MANUAL FETCH FOR PULL-TO-REFRESH ──
  Future<void> _loadFavourites() async {
    if (_uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      // 1. Get user's favourite IDs
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      final userData = userDoc.data() ?? {};
      final List<dynamic> favIds = userData['favouriteStoreIds'] ?? [];

      if (favIds.isEmpty) {
        if (mounted) {
          setState(() {
            _favouriteStores = [];
            _isLoading = false;
          });
        }
        return;
      }

      // 2. Fetch Store details for those IDs
      final storeSnap = await FirebaseFirestore.instance
          .collection('stores')
          .where(FieldPath.documentId, whereIn: favIds)
          .get();

      if (mounted) {
        setState(() {
          _favouriteStores = storeSnap.docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading favourites: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ── 4. INSTANT UI UPDATE WHEN REMOVING FAVOURITE ──
  Future<void> _removeFavourite(String storeId) async {
    if (_uid == null) return;

    // Remove from the screen instantly to feel snappy!
    setState(() {
      _favouriteStores.removeWhere((doc) => doc.id == storeId);
    });

    // Update Firebase silently in the background
    await FirebaseFirestore.instance.collection('users').doc(_uid).update({
      'favouriteStoreIds': FieldValue.arrayRemove([storeId])
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ── REQUIRED FOR KEEPALIVE ──

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // ── 5. WRAP WITH REFRESH INDICATOR ──
        child: RefreshIndicator(
          onRefresh: _loadFavourites,
          color: const Color(0xFF003E3B),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF003E3B)))
              : _favouriteStores.isEmpty
                  // We wrap the empty state in a scroll view so you can still pull down to refresh even when empty!
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.9,
                        alignment: Alignment.center,
                        child: _buildEmptyState(),
                      ),
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      itemCount: _favouriteStores.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      itemBuilder: (context, index) {
                        final data = _favouriteStores[index].data() as Map<String, dynamic>;
                        final storeId = _favouriteStores[index].id;
                        return _buildFavRow(context, data, storeId);
                      },
                    ),
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
            Image.asset(
              'assets/icons/MG_favourite_list.png',
              width: 160,
              height: 160,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.favorite_border,
                size: 120,
                color: Color(0xFF003E3B),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No favorites yet',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black,
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

  Widget _buildFavRow(BuildContext context, Map<String, dynamic> data, String storeId) {
    final store = Store(
      id: storeId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imagePath: data['imageUrl'] ?? '',
      logoPath: data['logoUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      category: data['category'] ?? 'General',
      distanceKm: (data['distanceKm'] ?? 0.0).toDouble(),
      products: [], 
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                store.logoPath,
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
            // Call our new snappier remove function!
            IconButton(
              icon: const Icon(Icons.favorite, color: Color(0xFF003E3B), size: 24),
              onPressed: () => _removeFavourite(storeId), 
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