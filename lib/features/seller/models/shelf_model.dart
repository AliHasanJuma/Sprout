import 'package:flutter/foundation.dart';

enum PriceType { fixed, startingAt }

@immutable
class SizeOption {
  final String size;
  final double price;

  const SizeOption({required this.size, required this.price});

  Map<String, dynamic> toMap() => {'size': size, 'price': price};

  factory SizeOption.fromMap(Map<String, dynamic> map) => SizeOption(
        size: map['size'] as String,
        price: (map['price'] as num).toDouble(),
      );
}

@immutable
class AddOnOption {
  final String name;
  final double price;

  const AddOnOption({required this.name, required this.price});

  Map<String, dynamic> toMap() => {'name': name, 'price': price};

  factory AddOnOption.fromMap(Map<String, dynamic> map) => AddOnOption(
        name: map['name'] as String,
        price: (map['price'] as num).toDouble(),
      );
}

@immutable
class ShelfModel {
  final String? id;
  final String name;
  final String description;
  final List<String> photoPaths;
  final PriceType priceType;
  final double price;
  final List<String> ingredients;
  final List<SizeOption> sizes;
  final List<AddOnOption> addOns;

  const ShelfModel({
    this.id,
    required this.name,
    required this.description,
    this.photoPaths = const [],
    this.priceType = PriceType.fixed,
    required this.price,
    this.ingredients = const [],
    this.sizes = const [],
    this.addOns = const [],
  });

  ShelfModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? photoPaths,
    PriceType? priceType,
    double? price,
    List<String>? ingredients,
    List<SizeOption>? sizes,
    List<AddOnOption>? addOns,
  }) {
    return ShelfModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photoPaths: photoPaths ?? this.photoPaths,
      priceType: priceType ?? this.priceType,
      price: price ?? this.price,
      ingredients: ingredients ?? this.ingredients,
      sizes: sizes ?? this.sizes,
      addOns: addOns ?? this.addOns,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'photoPaths': photoPaths,
        'priceType': priceType.name,
        'price': price,
        'ingredients': ingredients,
        'sizes': sizes.map((s) => s.toMap()).toList(),
        'addOns': addOns.map((a) => a.toMap()).toList(),
      };

  factory ShelfModel.fromMap(Map<String, dynamic> map) => ShelfModel(
        id: map['id'] as String?,
        name: map['name'] as String,
        description: map['description'] as String,
        photoPaths: List<String>.from(map['photoPaths'] as List? ?? []),
        priceType: PriceType.values.firstWhere(
          (e) => e.name == map['priceType'],
          orElse: () => PriceType.fixed,
        ),
        price: (map['price'] as num).toDouble(),
        ingredients: List<String>.from(map['ingredients'] as List? ?? []),
        sizes: (map['sizes'] as List? ?? [])
            .map((s) => SizeOption.fromMap(Map<String, dynamic>.from(s as Map)))
            .toList(),
        addOns: (map['addOns'] as List? ?? [])
            .map((a) => AddOnOption.fromMap(Map<String, dynamic>.from(a as Map)))
            .toList(),
      );
}
