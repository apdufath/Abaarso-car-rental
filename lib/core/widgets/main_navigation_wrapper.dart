import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_routes.dart';
import '../providers/app_settings_provider.dart';
import '../utils/helpers.dart';

class MainNavigationWrapper extends ConsumerWidget {
  final Widget child;

  const MainNavigationWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Check current locale
    final isSomali = ref.watch(appSettingsProvider).locale.languageCode == 'so';
    
    // Determine selected index based on active route
    final String location = GoRouterState.of(context).uri.path;
    int selectedIndex = 0;
    if (location.startsWith(AppRoutes.search)) {
      selectedIndex = 1;
    } else if (location.startsWith(AppRoutes.bookings)) {
      selectedIndex = 2;
    } else if (location.startsWith(AppRoutes.profile)) {
      selectedIndex = 3;
    }

    void onItemTapped(int index) {
      if (index == selectedIndex) return;
      Helpers.triggerHapticLight();
      
      switch (index) {
        case 0:
          context.go(AppRoutes.home);
          break;
        case 1:
          context.go(AppRoutes.search);
          break;
        case 2:
          context.go(AppRoutes.bookings);
          break;
        case 3:
          context.go(AppRoutes.profile);
          break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              activeIcon: const Icon(Icons.home_rounded, color: AppColors.primary),
              label: isSomali ? 'Hoyga' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search_rounded),
              activeIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              label: isSomali ? 'Raadi' : 'Search',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_rounded),
              activeIcon: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
              label: isSomali ? 'Dalabaadka' : 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              activeIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
              label: isSomali ? 'Koontada' : 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
