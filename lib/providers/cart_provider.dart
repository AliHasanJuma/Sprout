import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  // Singleton instance
  static final CartProvider _instance = CartProvider._internal();
  factory CartProvider() => _instance;
  CartProvider._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get grandTotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Items grouped by storeId
  Map<String, List<CartItem>> get itemsByStore {
    final map = <String, List<CartItem>>{};
    for (final item in _items) {
      map.putIfAbsent(item.storeId, () => []).add(item);
    }
    return map;
  }

  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQty) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (newQty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQty;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
