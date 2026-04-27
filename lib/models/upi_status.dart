enum UpiStatus {
  success,
  failure,
  pending,
  unknown;

  static UpiStatus fromRaw(String? raw) {
    if (raw == null) {
      return UpiStatus.unknown;
    }
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) {
      return UpiStatus.unknown;
    }
    if (value == 'success' || value == 's' || value == 'completed') {
      return UpiStatus.success;
    }
    if (value == 'pending' || value == 'submitted') {
      return UpiStatus.pending;
    }
    if (value == 'failure' || value == 'failed' || value == 'fail') {
      return UpiStatus.failure;
    }
    return UpiStatus.unknown;
  }
}
