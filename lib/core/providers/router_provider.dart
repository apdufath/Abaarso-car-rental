import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
import '../widgets/main_navigation_wrapper.dart';
import 'app_settings_provider.dart';

// Screens
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';

import '../../features/cars/presentation/screens/home_screen.dart';
import '../../features/cars/presentation/screens/search_screen.dart';
import '../../features/cars/presentation/screens/car_detail_screen.dart';

import '../../features/bookings/presentation/screens/booking_screen.dart';
import '../../features/bookings/presentation/screens/bookings_screen.dart';
import '../../features/bookings/presentation/screens/booking_detail_screen.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/fleet_management_screen.dart';
import '../../features/admin/presentation/screens/bookings_management_screen.dart';
import '../../features/admin/presentation/screens/users_management_screen.dart';
import '../../features/admin/presentation/screens/notifications_screen.dart';

// Auth State Providers
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/user_entity.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Listen to Auth State and Settings changes to trigger router redirection refresh
    _ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) {
        notifyListeners();
      },
    );
    _ref.listen<AppSettingsState>(
      appSettingsProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final settings = ref.read(appSettingsProvider);
      final authState = ref.read(authNotifierProvider);
      final user = authState.user;

      final isOnboarding = state.uri.path == AppRoutes.onboarding;
      final isLogin = state.uri.path == AppRoutes.login;
      final isRegister = state.uri.path == AppRoutes.register;
      final isProfileSetup = state.uri.path == AppRoutes.profileSetup;
      
      final isAuthRoute = isLogin || isRegister || isOnboarding;

      // 1. Check Onboarding First (First Run)
      if (settings.isFirstRun) {
        if (isOnboarding) return null;
        return AppRoutes.onboarding;
      }

      // If user tries to access Onboarding after completing it, send them to login or home
      if (isOnboarding && !settings.isFirstRun) {
        return user == null ? AppRoutes.login : AppRoutes.home;
      }

      // 2. Loading state -> no redirect yet
      if (authState.isLoading) {
        return null;
      }

      // 3. Unauthenticated User
      if (user == null) {
        if (authState.needsRegistration) {
          return isRegister ? null : AppRoutes.register;
        }
        // Allow public pages (Onboarding, Login)
        if (isAuthRoute) return null;
        // Gated paths -> Redirect to login
        return AppRoutes.login;
      }
      
      // 4. Authenticated User with missing KYC Documents
      final kycIncomplete = user.licenseImageUrl == null || user.idCardImageUrl == null;
      if (kycIncomplete && user.role != UserRole.admin) {
        if (isProfileSetup) return null;
        return AppRoutes.profileSetup;
      }

      // 5. Authenticated User (Fully Gated Pages check)
      if (isAuthRoute || (isProfileSetup && !kycIncomplete)) {
        if (user.role == UserRole.admin) {
          return AppRoutes.adminDashboard;
        }
        return AppRoutes.home;
      }

      // 6. Admin Route Gating
      final isAdminRoute = state.uri.path.startsWith('/admin');
      if (isAdminRoute && user.role != UserRole.admin) {
        return AppRoutes.home; // Kick customers out of admin routes
      }

      return null;
    },
    routes: [
      // Auth & Flow Pages
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Customer Core Navigation (Shell Route with BottomNavigationBar)
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: AppRoutes.bookings,
            builder: (context, state) => const BookingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Customer Non-tab Detail & Actions routes
      GoRoute(
        path: AppRoutes.carDetail,
        builder: (context, state) {
          final carId = state.pathParameters['carId'] ?? '';
          return CarDetailScreen(carId: carId);
        },
      ),
      GoRoute(
        path: AppRoutes.booking,
        builder: (context, state) {
          final carId = state.pathParameters['carId'] ?? '';
          return BookingScreen(carId: carId);
        },
      ),
      GoRoute(
        path: AppRoutes.bookingDetail,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? '';
          return BookingDetailScreen(bookingId: bookingId);
        },
      ),

      // Admin Dashboard & Gated Management Operations
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCars,
        builder: (context, state) => const FleetManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminBookings,
        builder: (context, state) => const BookingsManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        builder: (context, state) => const UsersManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminNotifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
