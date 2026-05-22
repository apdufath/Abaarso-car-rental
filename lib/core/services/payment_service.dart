import 'dart:async';
import '../../features/bookings/domain/booking_entity.dart';

class PaymentResult {
  final bool isSuccess;
  final String reference;
  final String? errorMessageEn;
  final String? errorMessageSo;

  PaymentResult({
    required this.isSuccess,
    required this.reference,
    this.errorMessageEn,
    this.errorMessageSo,
  });
}

class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  /// Initiates a push mobile money transaction.
  /// 
  /// Hormuud EVC Plus uses prefix 61 or 62 or 90 (+25261, +25262, +25290)
  /// Telesom Zaad uses prefix 63 (+25263)
  /// Somali Shilling equivalent is converted at 1 USD = 600 SOS flat rate
  Future<PaymentResult> initiateMobilePayment({
    required PaymentMethod method,
    required String phone,
    required double usdAmount,
  }) async {
    // Simulate API connection delay
    await Future.delayed(const Duration(seconds: 2));

    // Simple validation of phone prefix
    final cleanPhone = phone.replaceAll('+', '').replaceAll(' ', '');
    if (cleanPhone.length < 9) {
      return PaymentResult(
        isSuccess: false,
        reference: '',
        errorMessageEn: 'Invalid mobile number. Please double check.',
        errorMessageSo: 'Lambarku ma saxna. Fadlan dib u hubi.',
      );
    }

    // Determine prefix checks for Hormuud EVC vs Telesom Zaad
    if (method == PaymentMethod.evc && !(cleanPhone.contains('61') || cleanPhone.contains('62') || cleanPhone.contains('90') || cleanPhone.contains('68'))) {
      return PaymentResult(
        isSuccess: false,
        reference: '',
        errorMessageEn: 'EVC Plus is only available for Hormuud/Golis numbers.',
        errorMessageSo: 'EVC Plus waxaa lagu isticmaali karaa lambarada Hormuud/Golis oo kaliya.',
      );
    }

    if (method == PaymentMethod.zaad && !cleanPhone.contains('63')) {
      return PaymentResult(
        isSuccess: false,
        reference: '',
        errorMessageEn: 'Zaad service is only available for Telesom numbers (prefix 63).',
        errorMessageSo: 'Zaad waxaa lagu isticmaali karaa lambarada Telesom (hordhaca 63) oo kaliya.',
      );
    }

    // Simulate standard subscriber response delay (e.g. entering PIN on phone)
    await Future.delayed(const Duration(seconds: 2));

    // Provide a random reference ID
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final refCode = '${method.name.toUpperCase()}-$timestamp-TXT';

    // Successful transaction simulated
    return PaymentResult(
      isSuccess: true,
      reference: refCode,
    );
  }
}
