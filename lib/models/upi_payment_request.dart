import 'package:meta/meta.dart';

@immutable
class UpiPaymentRequest {
  const UpiPaymentRequest({
    required this.upiId,
    required this.name,
    required this.amount,
    this.note,
    this.currency = 'INR',
  });

  final String upiId;
  final String name;
  final double amount;
  final String? note;
  final String currency;
}
