import '../core/upi_sdk_exception.dart';
import '../models/upi_payment_request.dart';

class UpiValidators {
  static final RegExp _upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,}@[a-zA-Z]{2,}$');

  static void validateRequest(UpiPaymentRequest request) {
    validateUpiId(request.upiId);
    if (request.amount <= 0) {
      throw const UpiSdkException(
        'Amount must be greater than zero.',
        code: 'invalid_amount',
      );
    }
    if (request.name.trim().isEmpty) {
      throw const UpiSdkException(
        'Payee name cannot be empty.',
        code: 'invalid_name',
      );
    }
    if ((request.note ?? '').length > 80) {
      throw const UpiSdkException(
        'Note is too long. Keep note length under 80 characters.',
        code: 'invalid_note',
      );
    }
    if (request.currency.trim().toUpperCase() != 'INR') {
      throw const UpiSdkException(
        'Only INR currency is currently supported by this SDK.',
        code: 'invalid_currency',
      );
    }
  }

  static void validateUpiId(String upiId) {
    final normalized = upiId.trim();
    if (!_upiRegex.hasMatch(normalized)) {
      throw InvalidUpiIdException(
        'Invalid UPI ID "$upiId". Expected format like "name@bank".',
      );
    }
  }
}
