import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/shimmer_card.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../providers/cars_provider.dart';
import '../widgets/car_card.dart';
import '../../domain/car_entity.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _FilterBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredAsync = ref.watch(filteredCarsProvider);
    final selectedSort = ref.watch(carsSortOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Car'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search input + filter button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        ref.read(carsSearchQueryProvider.notifier).state = val;
                      },
                      style: theme.textTheme.titleMedium,
                      decoration: InputDecoration(
                        hintText: 'Search brand, model...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(carsSearchQueryProvider.notifier).state = '';
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filter trigger
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.24),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune_rounded, color: Colors.white),
                      onPressed: _showFilterBottomSheet,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Sort option row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _SortChip(
                      label: 'Newest',
                      selected: selectedSort == CarSortOption.newest,
                      onTap: () => ref.read(carsSortOptionProvider.notifier).state = CarSortOption.newest,
                    ),
                    _SortChip(
                      label: 'Price: Low - High',
                      selected: selectedSort == CarSortOption.priceLowToHigh,
                      onTap: () => ref.read(carsSortOptionProvider.notifier).state = CarSortOption.priceLowToHigh,
                    ),
                    _SortChip(
                      label: 'Price: High - Low',
                      selected: selectedSort == CarSortOption.priceHighToLow,
                      onTap: () => ref.read(carsSortOptionProvider.notifier).state = CarSortOption.priceHighToLow,
                    ),
                    _SortChip(
                      label: 'Rating',
                      selected: selectedSort == CarSortOption.rating,
                      onTap: () => ref.read(carsSortOptionProvider.notifier).state = CarSortOption.rating,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. GridView listing cars
            Expanded(
              child: filteredAsync.when(
                data: (cars) {
                  if (cars.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, color: Colors.grey.shade400, size: 64),
                            const SizedBox(height: 16),
                            const Text('No cars match your search filters.', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Try updating your text query or category filter.', style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cars.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, // Full card looks premium
                      childAspectRatio: 1.25,
                    ),
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      return CarCard(
                        car: car,
                        onTap: () {
                          context.push(AppRoutes.getCarDetailRoute(car.carId));
                        },
                      );
                    },
                  );
                },
                error: (e, st) => CustomErrorWidget(
                  errorMessage: e.toString(),
                  onRetry: () => ref.invalidate(carsListProvider),
                ),
                loading: () => ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) => ShimmerCard.carSkeleton(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (val) {
          if (val) onTap();
        },
      ),
    );
  }
}

// Elegant Bottom Sheet containing category filters and price sliders
class _FilterBottomSheet extends ConsumerStatefulWidget {
  const _FilterBottomSheet();

  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  double _priceLimit = 200.0;
  CarCategory? _category;

  @override
  void initState() {
    super.initState();
    _priceLimit = ref.read(carsMaxPriceFilterProvider) ?? 200.0;
    _category = ref.read(carsSelectedCategoryProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Filters', style: theme.textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Category Select
          Text('Vehicle Category', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (val) {
                  setState(() {
                    _category = null;
                  });
                },
              ),
              ...CarCategory.values.map((cat) {
                return ChoiceChip(
                  label: Text(cat.name.toUpperCase()),
                  selected: _category == cat,
                  onSelected: (val) {
                    setState(() {
                      _category = val ? cat : null;
                    });
                  },
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 24),

          // Price slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Max Daily Price', style: theme.textTheme.titleMedium),
              Text(
                '\$${_priceLimit.toInt()}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            min: 10,
            max: 200,
            divisions: 19,
            value: _priceLimit,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() {
                _priceLimit = val;
              });
            },
          ),
          const SizedBox(height: 32),

          // Apply and Reset Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(carsSelectedCategoryProvider.notifier).state = null;
                    ref.read(carsMaxPriceFilterProvider.notifier).state = null;
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(carsSelectedCategoryProvider.notifier).state = _category;
                    ref.read(carsMaxPriceFilterProvider.notifier).state = _priceLimit;
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
