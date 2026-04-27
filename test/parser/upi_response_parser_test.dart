import 'package:flutter_test/flutter_test.dart';
import 'package:upi_pro_sdk/models/upi_failure_type.dart';
import 'package:upi_pro_sdk/models/upi_status.dart';
import 'package:upi_pro_sdk/parser/upi_response_parser.dart';

void main() {
  group('UpiResponseParser.parse', () {
    const parser = UpiResponseParser();

    test('parses success response from rawResponse pairs', () {
      final response = parser.parse({
        'rawResponse':
            'Status=SUCCESS&txnId=TXN123&responseCode=00&ApprovalRefNo=APR1',
      });

      expect(response.status, UpiStatus.success);
      expect(response.txnId, 'TXN123');
      expect(response.responseCode, '00');
      expect(response.approvalRefNo, 'APR1');
      expect(response.failureType, UpiFailureType.unknown);
      expect(response.isSuccess, isTrue);
    });

    test('derives pending from responseCode when status is unknown', () {
      final response = parser.parse({
        'response': 'txnId=TXN234&responseCode=U16',
      });

      expect(response.status, UpiStatus.pending);
      expect(response.txnId, 'TXN234');
      expect(response.responseCode, 'U16');
      expect(response.isPending, isTrue);
    });

    test('captures explicit failureType from payload', () {
      final response = parser.parse({
        'status': 'FAILURE',
        'failureType': 'user_cancelled',
      });

      expect(response.status, UpiStatus.failure);
      expect(response.failureType, UpiFailureType.userCancelled);
      expect(response.isFailure, isTrue);
    });
  });
}
