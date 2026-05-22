import '../domain/car_entity.dart';
import 'car_remote_datasource.dart';

class CarRepository {
  final CarRemoteDataSource _remoteDataSource;

  CarRepository(this._remoteDataSource);

  Future<List<CarEntity>> fetchAllCars() async {
    return await _remoteDataSource.getCars();
  }

  Future<CarEntity?> fetchCarById(String carId) async {
    return await _remoteDataSource.getCarById(carId);
  }

  Future<void> createCar(CarEntity car) async {
    await _remoteDataSource.addCar(car);
  }

  Future<void> updateCar(CarEntity car) async {
    await _remoteDataSource.updateCar(car);
  }

  Future<void> removeCar(String carId) async {
    await _remoteDataSource.deleteCar(carId);
  }

  Future<void> updateAvailability(String carId, bool isAvailable) async {
    await _remoteDataSource.toggleCarAvailability(carId, isAvailable);
  }

  // Returns cars filtered by criteria
  Future<List<CarEntity>> getFilteredCars({
    String? query,
    CarCategory? category,
    double? maxPrice,
    bool? isAvailableOnly,
  }) async {
    final all = await fetchAllCars();
    return all.where((car) {
      // 1. Text Search matching Brand, Model or Category name
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        final brandMatch = car.brand.toLowerCase().contains(q);
        final modelMatch = car.model.toLowerCase().contains(q);
        final catMatch = car.category.name.toLowerCase().contains(q);
        if (!brandMatch && !modelMatch && !catMatch) return false;
      }
      // 2. Category selection match
      if (category != null && car.category != category) {
        return false;
      }
      // 3. Price limit
      if (maxPrice != null && car.pricePerDay > maxPrice) {
        return false;
      }
      // 4. Availability
      if (isAvailableOnly == true && !car.isAvailable) {
        return false;
      }
      return true;
    }).toList();
  }
}
