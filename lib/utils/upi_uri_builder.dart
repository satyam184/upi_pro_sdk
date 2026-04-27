import '../models/upi_payment_request.dart';

class UpiUriBuilder {
  const UpiUriBuilder();

  Uri build(UpiPaymentRequest request) {
    final params = <String, String>{
      'pa': request.upiId.trim(),
      'pn': request.name.trim(),
      'am': _normalizeAmount(request.amount),
      'cu': request.currency.trim().toUpperCase(),
    };
    final note = request.note?.trim();
    if (note != null && note.isNotEmpty) {
      params['tn'] = note;
    }
    return Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: params,
    );
  }

  String _normalizeAmount(double amount) {
    final fixed = amount.toStringAsFixed(2);
    if (fixed.endsWith('00')) {
      return fixed.substring(0, fixed.length - 3);
    }
    if (fixed.endsWith('0')) {
      return fixed.substring(0, fixed.length - 1);
    }
    return fixed;
  }
}
