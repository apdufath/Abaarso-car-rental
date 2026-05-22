import 'package:cloud_firestore/cloud_firestore.dart';

class LocationPoint {
  final double latitude;
  final double longitude;

  const LocationPoint(this.latitude, this.longitude);

  factory LocationPoint.fromGeoPoint(GeoPoint gp) {
    return LocationPoint(gp.latitude, gp.longitude);
  }

  GeoPoint toGeoPoint() {
    return GeoPoint(latitude, longitude);
  }
}

enum CarCategory {
  sedan,
  suv,
  pickup,
  minibus,
  luxury;

  String get name {
    switch (this) {
      case CarCategory.sedan:
        return 'sedan';
      case CarCategory.suv:
        return 'suv';
      case CarCategory.pickup:
        return 'pickup';
      case CarCategory.minibus:
        return 'minibus';
      case CarCategory.luxury:
        return 'luxury';
    }
  }

  static CarCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'suv':
        return CarCategory.suv;
      case 'pickup':
        return CarCategory.pickup;
      case 'minibus':
        return CarCategory.minibus;
      case 'luxury':
        return CarCategory.luxury;
      case 'sedan':
      default:
        return CarCategory.sedan;
    }
  }
}

class CarEntity {
  final String carId;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String plateNumber;
  final CarCategory category;
  final double pricePerDay;
  final String currency; // "USD" | "SOS"
  final bool isAvailable;
  final List<String> features;
  final List<String> images;
  final LocationPoint location;
  final String locationName;
  final String ownerId;
  final double averageRating;
  final int totalReviews;
  final DateTime createdAt;

  CarEntity({
    required this.carId,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.plateNumber,
    required this.category,
    required this.pricePerDay,
    required this.currency,
    required this.isAvailable,
    required this.features,
    required this.images,
    required this.location,
    required this.locationName,
    required this.ownerId,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'plateNumber': plateNumber,
      'category': category.name,
      'pricePerDay': pricePerDay,
      'currency': currency,
      'isAvailable': isAvailable,
      'features': features,
      'images': images,
      'location': location.toGeoPoint(),
      'locationName': locationName,
      'ownerId': ownerId,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CarEntity.fromMap(Map<String, dynamic> map) {
    LocationPoint locPoint;
    if (map['location'] is GeoPoint) {
      locPoint = LocationPoint.fromGeoPoint(map['location'] as GeoPoint);
    } else if (map['location'] is Map) {
      final locMap = map['location'] as Map;
      locPoint = LocationPoint(
        (locMap['latitude'] as num).toDouble(),
        (locMap['longitude'] as num).toDouble(),
      );
    } else {
      locPoint = const LocationPoint(9.5624, 44.0770); // Fallback to Hargeisa Sha'ab center coordinates
    }

    return CarEntity(
      carId: map['carId'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      year: (map['year'] as num).toInt(),
      color: map['color'] as String,
      plateNumber: map['plateNumber'] as String,
      category: CarCategory.fromString(map['category'] as String? ?? 'sedan'),
      pricePerDay: (map['pricePerDay'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      isAvailable: map['isAvailable'] as bool? ?? true,
      features: List<String>.from(map['features'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      location: locPoint,
      locationName: map['locationName'] as String? ?? "Hargeisa, Somaliland",
      ownerId: map['ownerId'] as String? ?? 'admin123',
      averageRating: (map['averageRating'] as num? ?? 0.0).toDouble(),
      totalReviews: (map['totalReviews'] as num? ?? 0).toInt(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
