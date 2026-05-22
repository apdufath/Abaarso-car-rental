// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Abaarso Car Rental';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get bookings => 'Bookings';

  @override
  String get profile => 'Profile';

  @override
  String get bookNow => 'Book Now';

  @override
  String get pricePerDay => 'Price per Day';

  @override
  String get availableNow => 'Available Now';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get payWithEVC => 'Pay with EVC Plus';

  @override
  String get payWithZaad => 'Pay with Zaad';

  @override
  String get payWithCash => 'Pay with Cash';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get nearYou => 'Near You';

  @override
  String get featuredCars => 'Featured Cars';

  @override
  String get searchHint => 'Search brand, model or category...';

  @override
  String get sedan => 'Sedan';

  @override
  String get suv => 'SUV';

  @override
  String get pickup => 'Pickup';

  @override
  String get minibus => 'Minibus';

  @override
  String get luxury => 'Luxury';

  @override
  String get all => 'All';

  @override
  String get active => 'Active';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get past => 'Past';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get completed => 'Completed';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get paid => 'Paid';

  @override
  String get refunded => 'Refunded';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get serviceFee => 'Service Fee';

  @override
  String get days => 'Days';

  @override
  String get rating => 'Rating';

  @override
  String get reviews => 'Reviews';

  @override
  String get features => 'Features';

  @override
  String get location => 'Location';

  @override
  String get driverNotes => 'Driver Notes (Optional)';

  @override
  String get enterDriverNotes => 'Any special instructions for driver...';

  @override
  String get login => 'Login / Register';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get sendOtp => 'Send Verification Code';

  @override
  String get verifyOtp => 'Verify Code';

  @override
  String get enterOtp => 'Enter the 6-digit code sent to your phone';

  @override
  String resendCode(Object seconds) {
    return 'Resend Code in ${seconds}s';
  }

  @override
  String get resendNow => 'Resend Code Now';

  @override
  String get register => 'Create Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get email => 'Email Address (Optional)';

  @override
  String get enterEmail => 'Enter your email address';

  @override
  String get role => 'I want to...';

  @override
  String get roleCustomer => 'Rent a Car';

  @override
  String get roleDriver => 'Be a Driver';

  @override
  String get profileSetup => 'Complete Profile Setup';

  @override
  String get uploadProfilePhoto => 'Profile Picture';

  @override
  String get uploadLicense => 'Driver\'s License Document';

  @override
  String get uploadId => 'National ID Card Document';

  @override
  String get verifiedBadge => 'Verified Profile';

  @override
  String get unverifiedBadge => 'Pending Verification';

  @override
  String get myReviews => 'My Reviews';

  @override
  String get favoriteCars => 'Favorite Cars';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get logout => 'Log Out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get fleetManagement => 'Fleet Management';

  @override
  String get bookingsManagement => 'Bookings Management';

  @override
  String get usersManagement => 'Users / KYC Management';

  @override
  String get revenue => 'Revenue Analysis';

  @override
  String get broadcast => 'Send Broadcast FCM';

  @override
  String get confirmDelete =>
      'Are you sure you want to delete your account? This action is irreversible.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get addCar => 'Add New Car';

  @override
  String get editCar => 'Edit Car';

  @override
  String get verifyUser => 'Verify KYC Documents';

  @override
  String get banUser => 'Ban User';

  @override
  String get unbanUser => 'Unban User';

  @override
  String get invalidPhone => 'Please enter a valid phone number';

  @override
  String get invalidName => 'Name cannot be empty';

  @override
  String get kycRequired =>
      'You must complete profile verification to book cars.';

  @override
  String get paymentPendingText =>
      'Waiting for USSD push confirmation on your phone...';

  @override
  String get paymentSuccessText =>
      'Payment received successfully! Your booking is confirmed.';

  @override
  String get paymentFailedText =>
      'Payment failed or was cancelled by the user.';

  @override
  String get unknownError => 'An unexpected error occurred. Please try again.';
}
