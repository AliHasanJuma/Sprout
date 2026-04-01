class CartItem {
  final String productId;
  final String productName;
  final String storeId;
  final String storeName;
  final double unitPrice;
  int quantity;
  final String? selectedSize;
  final List<String> selectedAddons;
  final double addonsTotal;
  final String? specialInstructions;
  final String? productImageUrl;

  CartItem({
    required this.productId,
    required this.productName,
    required this.storeId,
    required this.storeName,
    required this.unitPrice,
    this.quantity = 1,
    this.selectedSize,
    this.selectedAddons = const [],
    this.addonsTotal = 0,
    this.specialInstructions,
    this.productImageUrl,
  });

  double get totalPrice => (unitPrice + addonsTotal) * quantity;
}
