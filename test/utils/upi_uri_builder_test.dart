import 'package:flutter_test/flutter_test.dart';
import 'package:upi_pro_sdk/models/upi_payment_request.dart';
import 'package:upi_pro_sdk/utils/upi_uri_builder.dart';

void main() {
  group('UpiUriBuilder.build', () {
    const builder = UpiUriBuilder();

    test('builds an upi://pay URI with required parameters', () {
      const request = UpiPaymentRequest(
        upiId: 'merchant@okaxis',
        name: 'Coffee Shop',
        amount: 10,
      );

      final uri = builder.build(request);

      expect(uri.scheme, 'upi');
      expect(uri.host, 'pay');
      expect(uri.queryParameters['pa'], 'merchant@okaxis');
      expect(uri.queryParameters['pn'], 'Coffee Shop');
      expect(uri.queryParameters['am'], '10');
      expect(uri.queryParameters['cu'], 'INR');
      expect(uri.queryParameters.containsKey('tn'), isFalse);
    });

    test('keeps amount precision and includes note when present', () {
      const request = UpiPaymentRequest(
        upiId: 'merchant@okaxis',
        name: 'Coffee Shop',
        amount: 10.5,
        note: 'Morning order',
      );

      final uri = builder.build(request);

      expect(uri.queryParameters['am'], '10.5');
      expect(uri.queryParameters['tn'], 'Morning order');
    });
  });
}
