import 'package:flutter_test/flutter_test.dart';
import 'package:abaarso_car_rental/core/utils/validators.dart';
import 'package:abaarso_car_rental/core/utils/formatters.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validatePhone should return null for valid Somali phone numbers', () {
      expect(Validators.validatePhone('+252634444444'), null);
      expect(Validators.validatePhone('252634444444'), null);
      expect(Validators.validatePhone('+252907777777'), null);
    });

    test('validatePhone should return null for valid Kenyan phone numbers', () {
      expect(Validators.validatePhone('+254712345678'), null);
      expect(Validators.validatePhone('254722334455'), null);
    });

    test('validatePhone should return invalidPhone for bad formats', () {
      expect(Validators.validatePhone(''), 'invalidPhone');
      expect(Validators.validatePhone(null), 'invalidPhone');
      expect(Validators.validatePhone('+252034444444'), 'invalidPhone'); // prefix followed by 0
      expect(Validators.validatePhone('+251634444444'), 'invalidPhone'); // wrong country code
      expect(Validators.validatePhone('123456789'), 'invalidPhone'); // missing country code
    });

    test('validateName should validate minimum length requirements', () {
      expect(Validators.validateName('Ahmed'), null);
      expect(Validators.validateName('Abdi Farah'), null);
      expect(Validators.validateName(''), 'invalidName');
      expect(Validators.validateName('Al'), 'invalidName');
    });

    test('validateEmail should validate standard email strings', () {
      expect(Validators.validateEmail('test@abaarso.com'), null);
      expect(Validators.validateEmail(''), null); // Optional is allowed
      expect(Validators.validateEmail(null), null);
      expect(Validators.validateEmail('testemail'), 'Please enter a valid email address');
      expect(Validators.validateEmail('test@com'), 'Please enter a valid email address');
    });
  });

  group('Formatters Unit Tests', () {
    test('formatUSD should properly format money amounts', () {
      expect(Formatters.formatUSD(25.00), '\$25.00');
      expect(Formatters.formatUSD(1250.50), '\$1,250.50');
    });

    test('formatSOS should properly format Somali Shilling values', () {
      expect(Formatters.formatSOS(15000), 'SOS 15,000');
      expect(Formatters.formatSOS(500), 'SOS 500');
    });

    test('formatDualCurrency should display USD side-by-side with SOS converted rates', () {
      // 1 USD = 600 SOS
      expect(Formatters.formatDualCurrency(25.00, 'USD'), '\$25.00 (SOS 15,000)');
      expect(Formatters.formatDualCurrency(10.00, 'USD'), '\$10.00 (SOS 6,000)');
    });

    test('formatDualCurrency should display SOS side-by-side with USD converted rates', () {
      expect(Formatters.formatDualCurrency(15000.00, 'SOS'), 'SOS 15,000 (\$25.00)');
      expect(Formatters.formatDualCurrency(6000.00, 'SOS'), 'SOS 6,000 (\$10.00)');
    });
  });
}
