import 'dart:async';
import 'package:flutter/material.dart';
import '../data/temp_data.dart';
import 'store_page.dart';

/// Unified search result that can be a store or a product.
class _SearchResult {
  final String type; // 'Store' or 'Product'
  final String name;
  final String subtitle;
  final double rating;
  final String imagePath;
  final Store store; // the store to navigate to

  const _SearchResult({
    required this.type,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.imagePath,
    required this.store,
  });
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _recentSearches = List.from(tempRecentSearches);
  List<_SearchResult> _results = [];
  bool _isTyping = false;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    setState(() {
      _isTyping = query.isNotEmpty;
      if (query.isEmpty) {
        _results = [];
        return;
      }

      final q = query.toLowerCase();
      final results = <_SearchResult>[];

      for (final store in tempStores) {
        // Match store name/description
        if (store.name.toLowerCase().contains(q) ||
            store.description.toLowerCase().contains(q)) {
          results.add(_SearchResult(
            type: 'Store',
            name: store.name,
            subtitle: store.description,
            rating: store.rating,
            imagePath: store.imagePath,
            store: store,
          ));
        }

        // Match products within this store
        for (final product in store.products) {
          if (product.name.toLowerCase().contains(q) ||
              product.description.toLowerCase().contains(q)) {
            results.add(_SearchResult(
              type: 'Product',
              name: product.name,
              subtitle: '${store.name} · ${product.price} BD',
              rating: store.rating,
              imagePath: product.imagePath,
              store: store,
            ));
          }
        }
      }

      _results = results;
    });
  }

  void _onChipTapped(String text) {
    _controller.text = text;
    _controller.selection =
        TextSelection.fromPosition(TextPosition(offset: text.length));
    _performSearch(text);
  }

  void _clearAllRecent() {
    setState(() {
      _recentSearches.clear();
    });
    tempRecentSearches.clear();
  }

  void _navigateToStore(Store store, String query) {
    // Save to recent searches
    if (query.trim().isNotEmpty) {
      setState(() {
        _recentSearches.remove(query.trim());
        _recentSearches.insert(0, query.trim());
        if (_recentSearches.length > 10) {
          _recentSearches = _recentSearches.sublist(0, 10);
        }
      });
      tempRecentSearches
        ..clear()
        ..addAll(_recentSearches);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StorePage(store: store)),
    );
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
            // ── Top bar: back arrow + search field ──
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 24, top: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF003E3B), size: 24),
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
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                            offset: Offset(0, 3),
                            blurRadius: 20,
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText: 'Search for anything',
                          hintStyle: TextStyle(
                            color: Color(0xFFC3C3C3),
                            fontFamily: 'SF Pro Display',
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF003E3B),
                            size: 22,
                          ),
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

            // ── Body: recent searches or live results ──
            Expanded(
              child: _isTyping ? _buildLiveResults() : _buildRecentSearches(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent search',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.black, size: 24),
                onPressed: _clearAllRecent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _recentSearches.map((text) {
              return GestureDetector(
                onTap: () => _onChipTapped(text),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD0D0D0)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history,
                          size: 18, color: Color(0xFF9F9F9F)),
                      const SizedBox(width: 6),
                      Text(
                        text,
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveResults() {
    if (_results.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 16,
            color: Color(0xFF9F9F9F),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) {
        final result = _results[index];
        return _buildResultRow(result);
      },
    );
  }

  Widget _buildResultRow(_SearchResult result) {
    return GestureDetector(
      onTap: () => _navigateToStore(result.store, _controller.text.trim()),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                result.imagePath,
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
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          result.name,
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: result.type == 'Store'
                              ? const Color(0xFFCDEB45)
                              : const Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          result.type,
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.subtitle,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 12,
                      color: Color(0xFF9F9F9F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
