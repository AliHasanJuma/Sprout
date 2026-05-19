import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Lifecycle states for an order card.
enum OrderStatus {
  pending,
  active,
  ready,
  completed,
  rejected,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  bool get isTerminal =>
      this == OrderStatus.completed ||
      this == OrderStatus.rejected ||
      this == OrderStatus.cancelled;
}

/// A single line item on an order card.
class OrderItem {
  final String productId;
  final String name;
  // TODO(backend): pull description from products/shelves collection by productId.
  final String description;
  // TODO(backend): pull imageUrl from products/shelves collection by productId.
  final String? imageUrl;
  final int quantity;
  final double pricePerUnit;
  // TODO(schema): size and add-ons will plug in here.

  const OrderItem({
    required this.productId,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.quantity,
    required this.pricePerUnit,
  });

  double get lineTotal => pricePerUnit * quantity;

  OrderItem copyWith({
    String? productId,
    String? name,
    String? description,
    String? imageUrl,
    int? quantity,
    double? pricePerUnit,
  }) =>
      OrderItem(
        productId: productId ?? this.productId,
        name: name ?? this.name,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        quantity: quantity ?? this.quantity,
        pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'quantity': quantity,
        'pricePerUnit': pricePerUnit,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId: map['productId'] as String,
        name: map['name'] as String,
        description: (map['description'] as String?) ?? '',
        imageUrl: map['imageUrl'] as String?,
        quantity: (map['quantity'] as num).toInt(),
        pricePerUnit: (map['pricePerUnit'] as num).toDouble(),
      );
}

/// All the data the in-chat order card and its lifecycle screens need.
class OrderCardData {
  // TODO(backend): replace orderId with Firestore-generated doc ID.
  final String orderId;
  final String chatId;
  final String storeId;
  final String storeName;
  final String? storeAvatarUrl;
  final String buyerId;
  final String buyerName;
  final List<OrderItem> items;
  final String deliveryDetails;
  final double totalPrice;
  final OrderStatus status;
  final String pickupCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? rating;

  const OrderCardData({
    required this.orderId,
    required this.chatId,
    required this.storeId,
    required this.storeName,
    this.storeAvatarUrl,
    required this.buyerId,
    required this.buyerName,
    required this.items,
    required this.deliveryDetails,
    required this.totalPrice,
    required this.status,
    required this.pickupCode,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
  });

  /// Build a fresh pending order, generating orderId + pickupCode.
  factory OrderCardData.createPending({
    required String chatId,
    required String storeId,
    required String storeName,
    String? storeAvatarUrl,
    required String buyerId,
    required String buyerName,
    required List<OrderItem> items,
    required String deliveryDetails,
  }) {
    final now = DateTime.now();
    final total = items.fold<double>(0, (acc, i) => acc + i.lineTotal);
    return OrderCardData(
      orderId: _generateOrderId(),
      chatId: chatId,
      storeId: storeId,
      storeName: storeName,
      storeAvatarUrl: storeAvatarUrl,
      buyerId: buyerId,
      buyerName: buyerName,
      items: List.unmodifiable(items),
      deliveryDetails: deliveryDetails,
      totalPrice: total,
      status: OrderStatus.pending,
      pickupCode: _generatePickupCode(),
      createdAt: now,
      updatedAt: now,
    );
  }

  OrderCardData copyWith({
    OrderStatus? status,
    double? rating,
    DateTime? updatedAt,
  }) =>
      OrderCardData(
        orderId: orderId,
        chatId: chatId,
        storeId: storeId,
        storeName: storeName,
        storeAvatarUrl: storeAvatarUrl,
        buyerId: buyerId,
        buyerName: buyerName,
        items: items,
        deliveryDetails: deliveryDetails,
        totalPrice: totalPrice,
        status: status ?? this.status,
        pickupCode: pickupCode,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        rating: rating ?? this.rating,
      );

  Map<String, dynamic> toMap() => {
        'orderId': orderId,
        'chatId': chatId,
        'storeId': storeId,
        'storeName': storeName,
        'storeAvatarUrl': storeAvatarUrl,
        'buyerId': buyerId,
        'buyerName': buyerName,
        'items': items.map((i) => i.toMap()).toList(),
        'deliveryDetails': deliveryDetails,
        'totalPrice': totalPrice,
        'status': status.name,
        'pickupCode': pickupCode,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'rating': rating,
      };

  factory OrderCardData.fromMap(Map<String, dynamic> map) {
    DateTime parseTs(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return OrderCardData(
      orderId: map['orderId'] as String,
      chatId: map['chatId'] as String,
      storeId: map['storeId'] as String,
      storeName: map['storeName'] as String,
      storeAvatarUrl: map['storeAvatarUrl'] as String?,
      buyerId: map['buyerId'] as String,
      buyerName: map['buyerName'] as String,
      items: ((map['items'] as List?) ?? [])
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false),
      deliveryDetails: (map['deliveryDetails'] as String?) ?? '',
      totalPrice: (map['totalPrice'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      pickupCode: map['pickupCode'] as String,
      createdAt: parseTs(map['createdAt']),
      updatedAt: parseTs(map['updatedAt']),
      rating: (map['rating'] as num?)?.toDouble(),
    );
  }
}

String _generateOrderId() {
  final r = Random();
  return 'ord_${DateTime.now().millisecondsSinceEpoch}_${r.nextInt(99999).toString().padLeft(5, '0')}';
}

String _generatePickupCode() {
  final r = Random.secure();
  return r.nextInt(10000).toString().padLeft(4, '0');
}
