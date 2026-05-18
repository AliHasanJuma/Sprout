import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/temp_data.dart';
import 'store_page.dart';

class _SearchResult {
  final String type;
  final String name;
  final String subtitle;
  final double rating;
  final String imagePath;
  final String logoPath;
  final Map<String, dynamic> data;
  final String docId;
  final int relevanceScore; // ── ADDED RELEVANCE SCORE ──

  const _SearchResult({
    required this.type,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.imagePath,
    required this.logoPath,
    required this.data,
    required this.docId,
    required this.relevanceScore, // ── ADDED RELEVANCE SCORE ──
  });
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _recentSearches = []; 
  List<_SearchResult> _results = [];
  bool _isTyping = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches(); 
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveSearchQuery(String query) async {
    query = query.trim();
    if (query.isEmpty) return;

    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query); 
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10); 
      }
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  // ── UPDATED: SEARCH WITH SMART SORTING ──
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isTyping = false;
        _results = [];
      });
      return;
    }

    setState(() => _isTyping = true);
    final q = query.toLowerCase().trim();

    final snapshot = await FirebaseFirestore.instance.collection('stores').get();
    
    final results = <_SearchResult>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().toLowerCase();
      final desc = (data['description'] ?? '').toString().toLowerCase();

      int score = 0;

      // ── GRADING LOGIC ──
      if (name == q) {
        score = 100; // Exact match
      } else if (name.startsWith(q)) {
        score = 75;  // Starts with
      } else if (name.contains(q)) {
        score = 50;  // Contains
      } else if (desc.contains(q)) {
        score = 25;  // In description
      }

      if (score > 0) {
        results.add(_SearchResult(
          type: 'Store',
          name: data['name'] ?? 'Shop',
          subtitle: data['description'] ?? '',
          rating: (data['rating'] ?? 0.0).toDouble(),
          imagePath: data['imageUrl'] ?? '',
          logoPath: data['logoUrl'] ?? '',
          data: data,
          docId: doc.id,
          relevanceScore: score, // Pass the calculated score
        ));
      }
    }

    // Sort by highest score first
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    if (mounted) {
      setState(() => _results = results);
    }
  }

  void _onChipTapped(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
    _saveSearchQuery(text); 
    _performSearch(text);
  }

  Future<void> _clearAllRecent() async {
    setState(() => _recentSearches.clear());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
  }

  void _navigateToStore(_SearchResult result) async {
    final store = Store(
      id: result.docId,
      name: result.name,
      description: result.subtitle,
      imagePath: result.imagePath,
      logoPath: result.data['logoUrl'] ?? '',
      rating: result.rating,
      category: result.data['category'] ?? 'General',
      distanceKm: (result.data['distanceKm'] ?? 0.0).toDouble(),
      products: [], 
    );

    _saveSearchQuery(_controller.text);

    Navigator.push(context, MaterialPageRoute(builder: (_) => StorePage(store: store)));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        controller: _controller,
                        autofocus: true,
                        onChanged: _onSearchChanged,
                        onSubmitted: (value) {
                          _saveSearchQuery(value);
                        },
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText: 'Search for anything',
                          hintStyle: TextStyle(color: Color(0xFFC3C3C3), fontFamily: 'SF Pro Display', fontSize: 13),
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
            Expanded(child: _isTyping ? _buildLiveResults() : _buildRecentSearches()),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent search', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.delete_outline, size: 24), onPressed: _clearAllRecent),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: _recentSearches.map((text) => GestureDetector(
              onTap: () => _onChipTapped(text),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD0D0D0)), borderRadius: BorderRadius.circular(30)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history, size: 18, color: Color(0xFF9F9F9F)),
                    const SizedBox(width: 6),
                    Text(text, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveResults() {
    if (_results.isEmpty) return const Center(child: Text('No results found', style: TextStyle(color: Color(0xFF9F9F9F))));
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) => _buildResultRow(_results[index]),
    );
  }

  Widget _buildResultRow(_SearchResult result) {
    return GestureDetector(
      onTap: () => _navigateToStore(result),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                result.logoPath,
                width: 80, height: 80, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: const Color(0xFFD9D9D9)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(result.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: result.type == 'Store' ? const Color(0xFFCDEB45) : const Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(result.type, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(result.subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9F9F9F)), maxLines: 1),
                  const SizedBox(height: 6),
                  _buildStars(result.rating),
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