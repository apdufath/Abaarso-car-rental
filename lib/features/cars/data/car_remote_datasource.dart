import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/car_entity.dart';

abstract class CarRemoteDataSource {
  Future<List<CarEntity>> getCars();
  Future<CarEntity?> getCarById(String carId);
  Future<void> addCar(CarEntity car);
  Future<void> updateCar(CarEntity car);
  Future<void> deleteCar(String carId);
  Future<void> toggleCarAvailability(String carId, bool isAvailable);
}

class FirestoreCarRemoteDataSource implements CarRemoteDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreCarRemoteDataSource() {
    // Configure Firestore offline persistence automatically as requested:
    // "Offline support: cache car listings with Firestore offline persistence"
    try {
      _db.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (_) {
      // Settings can only be configured once. Catching in case they are already set.
    }
  }

  @override
  Future<List<CarEntity>> getCars() async {
    final snapshot = await _db.collection('cars').orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => CarEntity.fromMap(doc.data())).toList();
  }

  @override
  Future<CarEntity?> getCarById(String carId) async {
    final doc = await _db.collection('cars').doc(carId).get();
    if (!doc.exists || doc.data() == null) return null;
    return CarEntity.fromMap(doc.data()!);
  }

  @override
  Future<void> addCar(CarEntity car) async {
    await _db.collection('cars').doc(car.carId).set(car.toMap());
  }

  @override
  Future<void> updateCar(CarEntity car) async {
    await _db.collection('cars').doc(car.carId).update(car.toMap());
  }

  @override
  Future<void> deleteCar(String carId) async {
    await _db.collection('cars').doc(carId).delete();
  }

  @override
  Future<void> toggleCarAvailability(String carId, bool isAvailable) async {
    await _db.collection('cars').doc(carId).update({
      'isAvailable': isAvailable,
    });
  }
}

// Gorgeous fallback simulator for local demonstration
class SimulatedCarRemoteDataSource implements CarRemoteDataSource {
  final Map<String, CarEntity> _simulatedDb = {};

  SimulatedCarRemoteDataSource() {
    final now = DateTime.now();
    
    // Seed standard cars
    final cars = [
      CarEntity(
        carId: 'car_v8_1',
        brand: 'Toyota',
        model: 'Land Cruiser V8',
        year: 2021,
        color: 'Pearl White',
        plateNumber: 'SL 5234 HR',
        category: CarCategory.suv,
        pricePerDay: 90.0,
        currency: 'USD',
        isAvailable: true,
        features: ['AC', 'GPS', '4WD', 'Automatic', 'Leather Seats', 'Sunroof'],
        images: [
          'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=600&q=80',
          'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=600&q=80',
        ],
        location: const LocationPoint(9.5624, 44.0770), // Sha'ab, Hargeisa
        locationName: "Sha'ab, Hargeisa",
        ownerId: 'admin123',
        averageRating: 4.9,
        totalReviews: 28,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      CarEntity(
        carId: 'car_vitz_2',
        brand: 'Toyota',
        model: 'Vitz',
        year: 2018,
        color: 'Silver Grey',
        plateNumber: 'SL 1234 HR',
        category: CarCategory.sedan,
        pricePerDay: 18.0,
        currency: 'USD',
        isAvailable: true,
        features: ['AC', 'Automatic', 'Bluetooth', 'USB Charger', 'Keyless entry'],
        images: [
          'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?auto=format&fit=crop&w=600&q=80',
        ],
        location: const LocationPoint(9.5750, 44.0680), // Jigjiga Yar, Hargeisa
        locationName: "Jigjiga Yar, Hargeisa",
        ownerId: 'admin123',
        averageRating: 4.5,
        totalReviews: 12,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      CarEntity(
        carId: 'car_hilux_3',
        brand: 'Toyota',
        model: 'Hilux Revo',
        year: 2020,
        color: 'Metallic Grey',
        plateNumber: 'SL 8765 HR',
        category: CarCategory.pickup,
        pricePerDay: 55.0,
        currency: 'USD',
        isAvailable: true,
        features: ['AC', '4WD', 'Manual', 'GPS', 'Bluetooth', 'Heavy Suspension'],
        images: [
          'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=600&q=80',
        ],
        location: const LocationPoint(9.5540, 44.0720), // 26 June, Hargeisa
        locationName: "26 June, Hargeisa",
        ownerId: 'admin123',
        averageRating: 4.8,
        totalReviews: 19,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      CarEntity(
        carId: 'car_lx570_4',
        brand: 'Lexus',
        model: 'LX570 VIP',
        year: 2022,
        color: 'Black Metallic',
        plateNumber: 'SL 9999 HR',
        category: CarCategory.luxury,
        pricePerDay: 150.0,
        currency: 'USD',
        isAvailable: true,
        features: ['AC', 'GPS', '4WD', 'Automatic', 'Massage Seats', 'Bulletproof Glass', 'Premium Audio'],
        images: [
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=80',
        ],
        location: const LocationPoint(9.5600, 44.0820), // Sha'ab (Villas), Hargeisa
        locationName: "Sha'ab, Hargeisa",
        ownerId: 'admin123',
        averageRating: 5.0,
        totalReviews: 42,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      CarEntity(
        carId: 'car_noah_5',
        brand: 'Toyota',
        model: 'Noah',
        year: 2017,
        color: 'Dark Blue',
        plateNumber: 'SL 6423 HR',
        category: CarCategory.minibus,
        pricePerDay: 30.0,
        currency: 'USD',
        isAvailable: true,
        features: ['AC', 'Automatic', 'Dual Sliding Doors', '7-Seats', 'Reverse Camera'],
        images: [
          'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=600&q=80',
        ],
        location: const LocationPoint(9.5490, 44.0530), // Xeedho, Hargeisa
        locationName: "Xeedho, Hargeisa",
        ownerId: 'admin123',
        averageRating: 4.4,
        totalReviews: 9,
        createdAt: now.subtract(const Duration(days: 12)),
      ),
    ];

    for (var c in cars) {
      _simulatedDb[c.carId] = c;
    }
  }

  @override
  Future<List<CarEntity>> getCars() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _simulatedDb.values.toList();
  }

  @override
  Future<CarEntity?> getCarById(String carId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _simulatedDb[carId];
  }

  @override
  Future<void> addCar(CarEntity car) async {
    _simulatedDb[car.carId] = car;
  }

  @override
  Future<void> updateCar(CarEntity car) async {
    _simulatedDb[car.carId] = car;
  }

  @override
  Future<void> deleteCar(String carId) async {
    _simulatedDb.remove(carId);
  }

  @override
  Future<void> toggleCarAvailability(String carId, bool isAvailable) async {
    final car = _simulatedDb[carId];
    if (car != null) {
      _simulatedDb[carId] = CarEntity(
        carId: car.carId,
        brand: car.brand,
        model: car.model,
        year: car.year,
        color: car.color,
        plateNumber: car.plateNumber,
        category: car.category,
        pricePerDay: car.pricePerDay,
        currency: car.currency,
        isAvailable: isAvailable,
        features: car.features,
        images: car.images,
        location: car.location,
        locationName: car.locationName,
        ownerId: car.ownerId,
        averageRating: car.averageRating,
        totalReviews: car.totalReviews,
        createdAt: car.createdAt,
      );
    }
  }
}
