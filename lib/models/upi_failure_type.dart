enum UpiFailureType {
  none,
  userCancelled,
  timeout,
  appNotResponding,
  invalidRequest,
  platformError,
  unknown;

  static UpiFailureType fromRaw(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'user_cancelled':
        return UpiFailureType.userCancelled;
      case 'timeout':
        return UpiFailureType.timeout;
      case 'app_not_responding':
        return UpiFailureType.appNotResponding;
      case 'invalid_request':
        return UpiFailureType.invalidRequest;
      case 'platform_error':
        return UpiFailureType.platformError;
      default:
        return UpiFailureType.unknown;
    }
  }
}
