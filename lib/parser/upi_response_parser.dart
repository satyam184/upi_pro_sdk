import '../models/upi_failure_type.dart';
import '../models/upi_response.dart';
import '../models/upi_status.dart';

class UpiResponseParser {
  const UpiResponseParser();

  UpiResponse parse(Map<String, dynamic> payload) {
    final rawResponse = _asString(payload['rawResponse']);
    final responseMap = <String, String>{
      ..._extractPairs(rawResponse),
      ..._extractPairs(_asString(payload['response'])),
    };

    String? read(List<String> keys) {
      for (final key in keys) {
        if (responseMap.containsKey(key.toLowerCase())) {
          return responseMap[key.toLowerCase()];
        }
      }
      return _asString(payload[keys.first]);
    }

    final statusText = read(const ['status', 'Status', 'txnStatus']) ??
        _asString(payload['statusHint']);
    final status = _deriveStatus(statusText, read(const ['responseCode']));
    final failureType = UpiFailureType.fromRaw(_asString(payload['failureType']));

    return UpiResponse(
      status: status,
      txnId: read(
        const ['txnId', 'txnid', 'transactionId', 'TransactionId', 'tr'],
      ),
      responseCode: read(const ['responseCode', 'respCode', 'RespCode']),
      approvalRefNo: read(
        const ['approvalRefNo', 'ApprovalRefNo', 'txnRef', 'refId'],
      ),
      rawResponse: rawResponse,
      statusMessage: statusText,
      failureType: failureType,
    );
  }

  UpiStatus _deriveStatus(String? statusText, String? responseCode) {
    final parsed = UpiStatus.fromRaw(statusText);
    if (parsed != UpiStatus.unknown) {
      return parsed;
    }
    final code = responseCode?.trim();
    if (code == '00') {
      return UpiStatus.success;
    }
    if (code == 'U16' || code == 'ZM') {
      return UpiStatus.pending;
    }
    return UpiStatus.unknown;
  }

  Map<String, String> _extractPairs(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const <String, String>{};
    }
    final normalized = raw.replaceAll(';', '&');
    final output = <String, String>{};
    for (final token in normalized.split('&')) {
      if (token.trim().isEmpty || !token.contains('=')) {
        continue;
      }
      final parts = token.split('=');
      if (parts.length < 2) {
        continue;
      }
      final key = parts.first.trim().toLowerCase();
      final value = parts.skip(1).join('=').trim();
      if (key.isNotEmpty) {
        output[key] = value;
      }
    }
    return output;
  }

  String? _asString(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }
}
