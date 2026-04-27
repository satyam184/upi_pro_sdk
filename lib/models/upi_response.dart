import 'package:meta/meta.dart';

import 'upi_failure_type.dart';
import 'upi_status.dart';

@immutable
class UpiResponse {
  const UpiResponse({
    required this.status,
    this.txnId,
    this.responseCode,
    this.approvalRefNo,
    this.rawResponse,
    this.statusMessage,
    this.failureType = UpiFailureType.none,
  });

  final UpiStatus status;
  final String? txnId;
  final String? responseCode;
  final String? approvalRefNo;
  final String? rawResponse;
  final String? statusMessage;
  final UpiFailureType failureType;

  bool get isSuccess => status == UpiStatus.success;
  bool get isPending => status == UpiStatus.pending;
  bool get isFailure => status == UpiStatus.failure;
}
