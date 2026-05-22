class Validators {
  Validators._();

  // Matches +252 (Somalia/Somaliland) or +254 (Kenya) formats
  // Somali: +252 followed by 9 digits (e.g. +25263XXXXXXX, +25290XXXXXXX) or just 63XXXXXXX, 90XXXXXXX, etc.
  // Kenyan: +254 followed by 9 digits
  static final RegExp _phoneRegex = RegExp(r'^(\+?(252|254))[1-9][0-9]{8}$');
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'invalidPhone';
    }
    // Clean string by removing spaces and dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!_phoneRegex.hasMatch(cleanValue)) {
      return 'invalidPhone';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'invalidName';
    }
    if (value.trim().length < 3) {
      return 'invalidName';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional in onboarding
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
