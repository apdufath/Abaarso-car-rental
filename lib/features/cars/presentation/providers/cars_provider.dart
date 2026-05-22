import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/car_remote_datasource.dart';
import '../../data/car_repository.dart';
import '../../domain/car_entity.dart';

// Sort Options definition
enum CarSortOption {
  priceLowToHigh,
  priceHighToLow,
  rating,
  newest,
}

// 1. Data Source Provider
final carRemoteDataSourceProvider = Provider<CarRemoteDataSource>((ref) {
  try {
    if (Firebase.apps.isNotEmpty) {
      return FirestoreCarRemoteDataSource();
    }
  } catch (_) {}
  return SimulatedCarRemoteDataSource();
});

// 2. Repository Provider
final carRepositoryProvider = Provider<CarRepository>((ref) {
  final ds = ref.watch(carRemoteDataSourceProvider);
  return CarRepository(ds);
});

// 3. Main Cars List Provider
final carsListProvider = FutureProvider<List<CarEntity>>((ref) async {
  final repo = ref.watch(carRepositoryProvider);
  return await repo.fetchAllCars();
});

// 4. Search and Filter State Providers
final carsSearchQueryProvider = StateProvider<String>((ref) => '');
final carsSelectedCategoryProvider = StateProvider<CarCategory?>((ref) => null);
final carsMaxPriceFilterProvider = StateProvider<double?>((ref) => null);
final carsSortOptionProvider = StateProvider<CarSortOption>((ref) => CarSortOption.newest);

// 5. Dynamic Reacting Filtered Cars Provider
final filteredCarsProvider = Provider<AsyncValue<List<CarEntity>>>((ref) {
  final carsAsync = ref.watch(carsListProvider);
  final query = ref.watch(carsSearchQueryProvider);
  final category = ref.watch(carsSelectedCategoryProvider);
  final maxPrice = ref.watch(carsMaxPriceFilterProvider);
  final sortOption = ref.watch(carsSortOptionProvider);

  return carsAsync.when(
    data: (cars) {
      // Apply filters
      var list = cars.where((car) {
        if (query.isNotEmpty) {
          final q = query.toLowerCase();
          final brandMatch = car.brand.toLowerCase().contains(q);
          final modelMatch = car.model.toLowerCase().contains(q);
          if (!brandMatch && !modelMatch) return false;
        }
        if (category != null && car.category != category) return false;
        if (maxPrice != null && car.pricePerDay > maxPrice) return false;
        return true;
      }).toList();

      // Apply sorting
      switch (sortOption) {
        case CarSortOption.priceLowToHigh:
          list.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
          break;
        case CarSortOption.priceHighToLow:
          list.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
          break;
        case CarSortOption.rating:
          list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
          break;
        case CarSortOption.newest:
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }
      return AsyncValue.data(list);
    },
    error: (e, st) => AsyncValue.error(e, st),
    loading: () => const AsyncValue.loading(),
  );
});

// 6. State Notifier for Favorites (persisted locally via SharedPreferences)
class FavoriteCarsNotifier extends StateNotifier<List<String>> {
  FavoriteCarsNotifier() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList('favorite_cars') ?? [];
  }

  Future<void> toggleFavorite(String carId) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = List<String>.from(state);
    if (updated.contains(carId)) {
      updated.remove(carId);
    } else {
      updated.add(carId);
    }
    state = updated;
    await prefs.setStringList('favorite_cars', updated);
  }
}

final favoriteCarsProvider = StateNotifierProvider<FavoriteCarsNotifier, List<String>>((ref) {
  return FavoriteCarsNotifier();
});
