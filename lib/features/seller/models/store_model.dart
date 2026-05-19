import 'package:flutter/foundation.dart';

enum HandoffMethod { customerPickup, localDelivery, publicMeetup }

@immutable
class StoreLocation {
  final double lat;
  final double lng;
  final String address;

  const StoreLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  Map<String, dynamic> toMap() => {
        'lat': lat,
        'lng': lng,
        'address': address,
      };

  factory StoreLocation.fromMap(Map<String, dynamic> map) => StoreLocation(
        lat: (map['lat'] as num).toDouble(),
        lng: (map['lng'] as num).toDouble(),
        address: map['address'] as String,
      );
}

@immutable
class StoreModel {
  final String? id;
  final String name;
  final String bio;
  final String? category;
  final String? logoPath;
  final String? bannerPath;
  final StoreLocation? location;
  final List<HandoffMethod> handoffMethods;
  // TODO(ui): expose this in seller onboarding + store settings so sellers can edit it.
  final String defaultDeliveryDetails;

  const StoreModel({
    this.id,
    required this.name,
    required this.bio,
    this.category,
    this.logoPath,
    this.bannerPath,
    this.location,
    this.handoffMethods = const [],
    this.defaultDeliveryDetails = '',
  });

  StoreModel copyWith({
    String? id,
    String? name,
    String? bio,
    String? category,
    String? logoPath,
    String? bannerPath,
    StoreLocation? location,
    List<HandoffMethod>? handoffMethods,
    String? defaultDeliveryDetails,
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      category: category ?? this.category,
      logoPath: logoPath ?? this.logoPath,
      bannerPath: bannerPath ?? this.bannerPath,
      location: location ?? this.location,
      handoffMethods: handoffMethods ?? this.handoffMethods,
      defaultDeliveryDetails: defaultDeliveryDetails ?? this.defaultDeliveryDetails,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'bio': bio,
        'category': category,
        'logoPath': logoPath,
        'bannerPath': bannerPath,
        'location': location?.toMap(),
        'handoffMethods': handoffMethods.map((m) => m.name).toList(),
        'defaultDeliveryDetails': defaultDeliveryDetails,
      };

  factory StoreModel.fromMap(Map<String, dynamic> map) => StoreModel(
        id: map['id'] as String?,
        name: map['name'] as String,
        bio: map['bio'] as String,
        category: map['category'] as String?,
        logoPath: map['logoPath'] as String?,
        bannerPath: map['bannerPath'] as String?,
        location: map['location'] == null
            ? null
            : StoreLocation.fromMap(Map<String, dynamic>.from(map['location'] as Map)),
        handoffMethods: (map['handoffMethods'] as List? ?? [])
            .map((m) => HandoffMethod.values.firstWhere((e) => e.name == m))
            .toList(),
        defaultDeliveryDetails: (map['defaultDeliveryDetails'] as String?) ?? '',
      );
}
