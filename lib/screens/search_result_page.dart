import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added
import '../data/temp_data.dart';
import 'store_page.dart';

class SearchResultPage extends StatelessWidget {
  final String query;

  const SearchResultPage({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 24, top: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF003E3B), size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(70),
                        boxShadow: const [
                          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25), offset: Offset(0, 3), blurRadius: 20, spreadRadius: -8),
                        ],
                      ),
                      child: TextField(
                        controller: TextEditingController(text: query),
                        readOnly: true,
                        decoration: const InputDecoration(
                          hintText: 'Search results',
                          prefixIcon: Icon(Icons.search, color: Color(0xFF003E3B), size: 22),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // ── FUTURE BUILDER FOR DATABASE RESULTS ──
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('stores').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final q = query.toLowerCase();
                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final desc = (data['description'] ?? '').toString().toLowerCase();
                    return name.contains(q) || desc.contains(q);
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(child: Text('No results found', style: TextStyle(color: Color(0xFF9F9F9F))));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      // Map to Store model for navigation
                      final store = Store(
                        id: docs[index].id,
                        name: data['name'] ?? '',
                        description: data['description'] ?? '',
                        imagePath: data['imageUrl'] ?? '',
                        logoPath: data['logoUrl'] ?? '',
                        rating: (data['rating'] ?? 0.0).toDouble(),
                        category: data['category'] ?? 'General',
                        distanceKm: (data['distanceKm'] ?? 0.0).toDouble(),
                        products: [],
                      );
                      return _buildStoreRow(context, store);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreRow(BuildContext context, Store store) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StorePage(store: store))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                store.imagePath,
                width: 80, height: 80, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: const Color(0xFFD9D9D9)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(store.description, style: const TextStyle(fontSize: 12, color: Color(0xFF9F9F9F)), maxLines: 1),
                  const SizedBox(height: 6),
                  _buildStars(store.rating),
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
        return Icon(full ? Icons.star : half ? Icons.star_half : Icons.star_border, size: 13, color: Colors.amber);
      }),
    );
  }
}