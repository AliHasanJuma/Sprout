import '../models/shelf_model.dart';

class ShelfService {
  ShelfService._internal();
  static final ShelfService _instance = ShelfService._internal();
  factory ShelfService() => _instance;

  final List<ShelfModel> _shelves = [];

  Future<void> createShelf(ShelfModel shelf) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final withId = shelf.copyWith(
      id: shelf.id ?? 'shelf-${DateTime.now().millisecondsSinceEpoch}',
    );
    _shelves.add(withId);
    // TODO: replace with Firestore write.
  }

  Future<List<ShelfModel>> getMyShelves() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_shelves);
    // TODO: replace with Firestore stream/query.
  }

  Future<ShelfModel?> getShelf(String shelfId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (final shelf in _shelves) {
      if (shelf.id == shelfId) return shelf;
    }
    return null;
    // TODO: replace with Firestore doc read.
  }

  Future<void> updateShelf(ShelfModel shelf) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _shelves.indexWhere((s) => s.id == shelf.id);
    if (index != -1) _shelves[index] = shelf;
    // TODO: replace with Firestore update.
  }

  Future<void> deleteShelf(String shelfId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _shelves.removeWhere((s) => s.id == shelfId);
    // TODO: replace with Firestore delete + Storage cleanup.
  }
}
