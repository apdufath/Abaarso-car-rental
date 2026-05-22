import 'package:cloud_firestore/cloud_firestore.dart';
import '../../cars/domain/car_entity.dart';

enum BookingStatus {
  pending,
  approved, // Maps to 'confirmed' in Firestore
  active,
  completed,
  cancelled;

  String get name {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.approved:
        return 'confirmed'; // Serializes as 'confirmed'
      case BookingStatus.active:
        return 'active';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'approved':
        return BookingStatus.approved;
      case 'active':
        return BookingStatus.active;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'pending':
      default:
        return BookingStatus.pending;
    }
  }
}

enum PaymentStatus {
  pending, // Maps to 'unpaid' in Firestore
  paid,
  failed;  // Maps to 'refunded' in Firestore

  String get name {
    switch (this) {
      case PaymentStatus.pending:
        return 'unpaid'; // Serializes as 'unpaid'
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.failed:
        return 'refunded'; // Serializes as 'refunded'
    }
  }

  static PaymentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
      case 'failed':
        return PaymentStatus.failed;
      case 'unpaid':
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }
}

enum PaymentMethod {
  evc, // Maps to 'evc_plus' in Firestore
  zaad,
  cash;

  String get name {
    switch (this) {
      case PaymentMethod.evc:
        return 'evc_plus'; // Serializes as 'evc_plus'
      case PaymentMethod.zaad:
        return 'zaad';
      case PaymentMethod.cash:
        return 'cash';
    }
  }

  static PaymentMethod fromString(String method) {
    switch (method.toLowerCase()) {
      case 'zaad':
        return PaymentMethod.zaad;
      case 'cash':
        return PaymentMethod.cash;
      case 'evc_plus':
      case 'evc':
      default:
        return PaymentMethod.evc;
    }
  }
}

class BookingEntity {
  final String bookingId;
  final String userId;
  final String carId;
  final String carBrandModel;
  final String carPlateNumber;
  final String? carImageUrl;
  final String userName;
  final String userPhone;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final double totalPrice; // in USD
  final String currency; // "USD"
  final BookingStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? paymentReference;
  final String? notes; // Maps to 'driverNotes' in Firestore
  final String pickupLocation; // Maps to 'pickupLocationName' in Firestore
  final LocationPoint pickupCoords; // Maps to 'pickupLocation' (GeoPoint) in Firestore
  final String dropoffLocation; // Maps to 'dropoffLocationName' in Firestore
  final LocationPoint dropoffCoords; // Maps to 'dropoffLocation' (GeoPoint) in Firestore
  final DateTime createdAt;

  BookingEntity({
    required this.bookingId,
    required this.userId,
    required this.carId,
    required this.carBrandModel,
    required this.carPlateNumber,
    this.carImageUrl,
    required this.userName,
    required this.userPhone,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalPrice,
    this.currency = 'USD',
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentReference,
    this.notes,
    required this.pickupLocation,
    required this.pickupCoords,
    required this.dropoffLocation,
    required this.dropoffCoords,
    required this.createdAt,
  });

  BookingEntity copyWith({
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentReference,
  }) {
    return BookingEntity(
      bookingId: bookingId,
      userId: userId,
      carId: carId,
      carBrandModel: carBrandModel,
      carPlateNumber: carPlateNumber,
      carImageUrl: carImageUrl,
      userName: userName,
      userPhone: userPhone,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      totalPrice: totalPrice,
      currency: currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentReference: paymentReference ?? this.paymentReference,
      notes: notes,
      pickupLocation: pickupLocation,
      pickupCoords: pickupCoords,
      dropoffLocation: dropoffLocation,
      dropoffCoords: dropoffCoords,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'carId': carId,
      'carBrandModel': carBrandModel,
      'carPlateNumber': carPlateNumber,
      'carImageUrl': carImageUrl,
      'userName': userName,
      'userPhone': userPhone,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalDays': totalDays,
      'totalPrice': totalPrice,
      'currency': currency,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'paymentReference': paymentReference,
      'driverNotes': notes, // Mapped to 'driverNotes'
      'pickupLocationName': pickupLocation, // Mapped to 'pickupLocationName'
      'pickupLocation': pickupCoords.toGeoPoint(), // Mapped to 'pickupLocation' as GeoPoint
      'dropoffLocationName': dropoffLocation, // Mapped to 'dropoffLocationName'
      'dropoffLocation': dropoffCoords.toGeoPoint(), // Mapped to 'dropoffLocation' as GeoPoint
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BookingEntity.fromMap(Map<String, dynamic> map) {
    // 1. Resolve pickup coords/location GeoPoint
    LocationPoint pickCoords;
    final rawPickupLoc = map['pickupLocation'];
    final rawPickupCoords = map['pickupCoords'];
    if (rawPickupLoc is GeoPoint) {
      pickCoords = LocationPoint.fromGeoPoint(rawPickupLoc);
    } else if (rawPickupCoords is GeoPoint) {
      pickCoords = LocationPoint.fromGeoPoint(rawPickupCoords);
    } else if (rawPickupCoords is Map) {
      final m = rawPickupCoords;
      pickCoords = LocationPoint((m['latitude'] as num).toDouble(), (m['longitude'] as num).toDouble());
    } else {
      pickCoords = const LocationPoint(9.5624, 44.0770);
    }

    // 2. Resolve dropoff coords/location GeoPoint
    LocationPoint dropCoords;
    final rawDropoffLoc = map['dropoffLocation'];
    final rawDropoffCoords = map['dropoffCoords'];
    if (rawDropoffLoc is GeoPoint) {
      dropCoords = LocationPoint.fromGeoPoint(rawDropoffLoc);
    } else if (rawDropoffCoords is GeoPoint) {
      dropCoords = LocationPoint.fromGeoPoint(rawDropoffCoords);
    } else if (rawDropoffCoords is Map) {
      final m = rawDropoffCoords;
      dropCoords = LocationPoint((m['latitude'] as num).toDouble(), (m['longitude'] as num).toDouble());
    } else {
      dropCoords = const LocationPoint(9.5624, 44.0770);
    }

    // 3. Resolve friendly pickup/dropoff location name strings
    final String pickName = map['pickupLocationName'] as String? ?? 
                         (map['pickupLocation'] is String ? map['pickupLocation'] as String : '');
    
    final String dropName = map['dropoffLocationName'] as String? ?? 
                         (map['dropoffLocation'] is String ? map['dropoffLocation'] as String : '');

    return BookingEntity(
      bookingId: map['bookingId'] as String,
      userId: map['userId'] as String,
      carId: map['carId'] as String,
      carBrandModel: map['carBrandModel'] as String? ?? '',
      carPlateNumber: map['carPlateNumber'] as String? ?? '',
      carImageUrl: map['carImageUrl'] as String?,
      userName: map['userName'] as String? ?? '',
      userPhone: map['userPhone'] as String? ?? '',
      startDate: map['startDate'] is Timestamp
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: map['endDate'] is Timestamp
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['endDate']?.toString() ?? '') ?? DateTime.now(),
      totalDays: (map['totalDays'] as num? ?? 1).toInt(),
      totalPrice: (map['totalPrice'] as num? ?? 0.0).toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      status: BookingStatus.fromString(map['status'] as String? ?? 'pending'),
      paymentMethod: PaymentMethod.fromString(map['paymentMethod'] as String? ?? 'evc_plus'),
      paymentStatus: PaymentStatus.fromString(map['paymentStatus'] as String? ?? 'unpaid'),
      paymentReference: map['paymentReference'] as String?,
      notes: map['driverNotes'] as String? ?? map['notes'] as String?, // Supports both
      pickupLocation: pickName,
      pickupCoords: pickCoords,
      dropoffLocation: dropName,
      dropoffCoords: dropCoords,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
