class AppRoutes {
  AppRoutes._();

  static const String login = '/';
  static const String onboarding = '/onboarding';
  static const String register = '/register';
  static const String profileSetup = '/profile-setup';

  // Customer Bottom Navigation Paths
  static const String home = '/home';
  static const String search = '/search';
  static const String bookings = '/bookings';
  static const String profile = '/profile';

  // Detail & Process Paths
  static const String carDetail = '/car/:carId';
  static const String booking = '/book/:carId';
  static const String bookingDetail = '/booking-detail/:bookingId';

  // Admin Module Paths
  static const String adminDashboard = '/admin';
  static const String adminCars = '/admin/cars';
  static const String adminBookings = '/admin/bookings';
  static const String adminUsers = '/admin/users';
  static const String adminRevenue = '/admin/revenue';
  static const String adminNotifications = '/admin/notifications';

  // Helper route generators
  static String getCarDetailRoute(String carId) => '/car/$carId';
  static String getBookingRoute(String carId) => '/book/$carId';
  static String getBookingDetailRoute(String bookingId) => '/booking-detail/$bookingId';
}
