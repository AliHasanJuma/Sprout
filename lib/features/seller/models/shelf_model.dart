import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum PriceType { fixed, startingAt }

@immutable
class SizeOption {
  final String size;
  final double priceModifier;

  const SizeOption({required this.size, required this.priceModifier});

  Map<String, dynamic> toMap() => {'size': size, 'priceModifier': priceModifier};

  factory SizeOption.fromMap(Map<String, dynamic> map) => SizeOption(
        size: map['size'] as String,
        priceModifier: (map['priceModifier'] as num).toDouble(),
      );
}

@immutable
class AddOnOption {
  final String name;
  final double priceModifier;

  const AddOnOption({required this.name, required this.priceModifier});

  Map<String, dynamic> toMap() => {'name': name, 'priceModifier': priceModifier};

  factory AddOnOption.fromMap(Map<String, dynamic> map) => AddOnOption(
        name: map['name'] as String,
        priceModifier: (map['priceModifier'] as num).toDouble(),
      );
}

@immutable
class ShelfModel {
  final String? id;
  final String storeId;
  final String name;
  final String description;
  final List<String> photoPaths;
  final PriceType priceType;
  final double price;
  final List<String> ingredients;
  final List<SizeOption> sizes;
  final List<AddOnOption> addOns;
  final DateTime? createdAt;

  const ShelfModel({
    this.id,
    required this.storeId,
    required this.name,
    required this.description,
    this.photoPaths = const [],
    this.priceType = PriceType.fixed,
    required this.price,
    this.ingredients = const [],
    this.sizes = const [],
    this.addOns = const [],
    this.createdAt,
  });

  ShelfModel copyWith({
    String? id,
    String? storeId,
    String? name,
    String? description,
    List<String>? photoPaths,
    PriceType? priceType,
    double? price,
    List<String>? ingredients,
    List<SizeOption>? sizes,
    List<AddOnOption>? addOns,
    DateTime? createdAt,
  }) {
    return ShelfModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      photoPaths: photoPaths ?? this.photoPaths,
      priceType: priceType ?? this.priceType,
      price: price ?? this.price,
      ingredients: ingredients ?? this.ingredients,
      sizes: sizes ?? this.sizes,
      addOns: addOns ?? this.addOns,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'storeId': storeId,
        'name': name,
        'description': description,
        'photoPaths': photoPaths,
        'priceType': priceType.name,
        'price': price,
        'ingredients': ingredients,
        'sizes': sizes.map((s) => s.toMap()).toList(),
        'addOns': addOns.map((a) => a.toMap()).toList(),
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      };

  factory ShelfModel.fromMap(Map<String, dynamic> map, String documentId) => ShelfModel(
        id: documentId,
        storeId: map['storeId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        photoPaths: List<String>.from(map['photoPaths'] as List? ?? []),
        priceType: PriceType.values.firstWhere(
          (e) => e.name == map['priceType'],
          orElse: () => PriceType.fixed,
        ),
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        ingredients: List<String>.from(map['ingredients'] as List? ?? []),
        sizes: (map['sizes'] as List? ?? [])
            .map((s) => SizeOption.fromMap(Map<String, dynamic>.from(s as Map)))
            .toList(),
        addOns: (map['addOns'] as List? ?? [])
            .map((a) => AddOnOption.fromMap(Map<String, dynamic>.from(a as Map)))
            .toList(),
        createdAt: map['createdAt'] != null 
            ? (map['createdAt'] as Timestamp).toDate() 
            : null,
      );
}