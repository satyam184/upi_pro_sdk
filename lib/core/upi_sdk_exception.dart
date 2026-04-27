class UpiSdkException implements Exception {
  const UpiSdkException(this.message, {this.code, this.details});

  final String message;
  final String? code;
  final Object? details;

  @override
  String toString() {
    if (code == null) {
      return 'UpiSdkException($message)';
    }
    return 'UpiSdkException[$code]($message)';
  }
}

class NoUpiAppFoundException extends UpiSdkException {
  const NoUpiAppFoundException()
      : super(
          'No verified UPI applications found on this device.',
          code: 'no_upi_app_found',
        );
}

class InvalidUpiIdException extends UpiSdkException {
  const InvalidUpiIdException(super.message)
      : super(code: 'invalid_upi_id');
}

class PaymentCancelledException extends UpiSdkException {
  const PaymentCancelledException({String? details})
      : super(
          details ?? 'Payment was cancelled by the user.',
          code: 'payment_cancelled',
        );
}

class TimeoutException extends UpiSdkException {
  const TimeoutException({String? details})
      : super(
          details ?? 'Payment timed out before receiving a UPI response.',
          code: 'payment_timeout',
        );
}

class AppNotRespondingException extends UpiSdkException {
  const AppNotRespondingException()
      : super(
          'Selected UPI app did not provide a response.',
          code: 'app_not_responding',
        );
}

class PaymentFailedException extends UpiSdkException {
  const PaymentFailedException({String? details})
      : super(
          details ?? 'UPI payment failed.',
          code: 'payment_failed',
        );
}
