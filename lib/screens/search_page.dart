// TODO: Replace with Firebase
import 'package:flutter/material.dart';
import '../data/temp_data.dart';
import 'search_result_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _recentSearches = List.from(tempRecentSearches);
  List<Store> _filteredStores = [];
  bool _isTyping = false;

  void _onSearchChanged(String query) {
    setState(() {
      _isTyping = query.isNotEmpty;
      if (query.isNotEmpty) {
        _filteredStores = tempStores
            .where((s) =>
                s.name.toLowerCase().contains(query.toLowerCase()) ||
                s.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        _filteredStores = [];
      }
    });
  }

  void _submitSearch(String query) {
    if (query.trim().isEmpty) return;
    // Add to recent searches
    setState(() {
      _recentSearches.remove(query.trim());
      _recentSearches.insert(0, query.trim());
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
    // Update global temp list
    tempRecentSearches
      ..clear()
      ..addAll(_recentSearches);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultPage(query: query.trim()),
      ),
    );
  }

  void _onChipTapped(String text) {
    _controller.text = text;
    _controller.selection =
        TextSelection.fromPosition(TextPosition(offset: text.length));
    _onSearchChanged(text);
  }

  void _clearAllRecent() {
    setState(() {
      _recentSearches.clear();
    });
    tempRecentSearches.clear();
  }

  @override
  void dispose() {
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
                        onSubmitted: _submitSearch,
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
          // Title row
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
          // Chips
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
    if (_filteredStores.isEmpty) {
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
      itemCount: _filteredStores.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) {
        final store = _filteredStores[index];
        return _buildStoreRow(store);
      },
    );
  }

  Widget _buildStoreRow(Store store) {
    return GestureDetector(
      onTap: () => _submitSearch(store.name),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Store image
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
