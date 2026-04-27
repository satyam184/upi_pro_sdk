import 'package:meta/meta.dart';

import 'upi_payment_request.dart';
import 'upi_response.dart';

typedef PaymentInitiatedHook = void Function(UpiPaymentRequest request);
typedef AppLaunchedHook = void Function(String appIdentifier);
typedef ResponseReceivedHook = void Function(UpiResponse response);
typedef FailureHook = void Function(Object error);
typedef TimeoutHook = void Function();

@immutable
class UpiAnalyticsHooks {
  const UpiAnalyticsHooks({
    this.onPaymentInitiated,
    this.onAppLaunched,
    this.onResponseReceived,
    this.onFailure,
    this.onTimeout,
  });

  final PaymentInitiatedHook? onPaymentInitiated;
  final AppLaunchedHook? onAppLaunched;
  final ResponseReceivedHook? onResponseReceived;
  final FailureHook? onFailure;
  final TimeoutHook? onTimeout;
}
