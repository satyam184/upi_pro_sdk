import 'package:flutter_test/flutter_test.dart';
import 'package:upi_pro_sdk/core/upi_sdk_exception.dart';
import 'package:upi_pro_sdk/models/upi_payment_request.dart';
import 'package:upi_pro_sdk/utils/upi_validators.dart';

void main() {
  group('UpiValidators.validateUpiId', () {
    test('accepts a well-formed UPI ID', () {
      expect(
        () => UpiValidators.validateUpiId('alice@okaxis'),
        returnsNormally,
      );
    });

    test('throws InvalidUpiIdException for malformed UPI ID', () {
      expect(
        () => UpiValidators.validateUpiId('alice-at-okaxis'),
        throwsA(isA<InvalidUpiIdException>()),
      );
    });
  });

  group('UpiValidators.validateRequest', () {
    const validRequest = UpiPaymentRequest(
      upiId: 'merchant@paytm',
      name: 'Merchant Name',
      amount: 1.5,
      note: 'Tea payment',
      currency: 'INR',
    );

    test('accepts a valid request', () {
      expect(
        () => UpiValidators.validateRequest(validRequest),
        returnsNormally,
      );
    });

    test('rejects non-positive amount', () {
      const request = UpiPaymentRequest(
        upiId: 'merchant@paytm',
        name: 'Merchant Name',
        amount: 0,
      );

      expect(
        () => UpiValidators.validateRequest(request),
        throwsA(
          isA<UpiSdkException>().having(
            (e) => e.code,
            'code',
            'invalid_amount',
          ),
        ),
      );
    });

    test('rejects non-INR currency', () {
      const request = UpiPaymentRequest(
        upiId: 'merchant@paytm',
        name: 'Merchant Name',
        amount: 10,
        currency: 'USD',
      );

      expect(
        () => UpiValidators.validateRequest(request),
        throwsA(
          isA<UpiSdkException>().having(
            (e) => e.code,
            'code',
            'invalid_currency',
          ),
        ),
      );
    });
  });
}
