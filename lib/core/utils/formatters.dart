import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final NumberFormat _sosFormat = NumberFormat.currency(symbol: 'SOS ', decimalDigits: 0);

  static String formatUSD(double amount) {
    return _usdFormat.format(amount);
  }

  static String formatSOS(double amount) {
    return _sosFormat.format(amount);
  }

  // Returns dual currency formatted string, e.g. "$25.00 (15,000 SOS)" or "SOS 15,000 ($25.00)"
  static String formatDualCurrency(double amount, String originalCurrency) {
    if (originalCurrency == 'USD') {
      final double sosAmount = amount * AppStrings.usdToSosRate;
      return '${formatUSD(amount)} (${formatSOS(sosAmount)})';
    } else {
      final double usdAmount = amount / AppStrings.usdToSosRate;
      return '${formatSOS(amount)} (${formatUSD(usdAmount)})';
    }
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateRange(DateTime start, DateTime end) {
    return '${formatDate(start)} - ${formatDate(end)}';
  }
}
