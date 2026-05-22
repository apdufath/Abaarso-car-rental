class AppStrings {
  AppStrings._();

  // Shared preferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguageCode = 'language_code';
  static const String keyFirstRun = 'first_run';

  // Firestore collections
  static const String colUsers = 'users';
  static const String colCars = 'cars';
  static const String colBookings = 'bookings';
  static const String colReviews = 'reviews';
  static const String colNotifications = 'notifications';

  // Remote config or payment parameters
  static const String defaultCurrency = 'USD';
  static const String fallbackCurrency = 'SOS';
  static const double usdToSosRate = 600.0; // Simulated flat rate for Somalia/Somaliland (approx 1 USD = 600 SOS)
}
