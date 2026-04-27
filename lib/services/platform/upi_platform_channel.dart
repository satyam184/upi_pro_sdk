import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class UpiPlatformChannel {
  UpiPlatformChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(_methodChannelName);

  static const String _methodChannelName = 'upi_pro_sdk/methods';
  final MethodChannel _channel;

  @visibleForTesting
  MethodChannel get channel => _channel;

  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    final rawResult = await _channel.invokeMethod<List<Object?>>(
      'getInstalledApps',
    );
    final entries = rawResult ?? const <Object?>[];
    return entries
        .whereType<Map<Object?, Object?>>()
        .map((item) => item.map(
              (key, value) => MapEntry(key.toString(), value),
            ))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> pay({
    required String upiUri,
    String? targetAppId,
    int timeoutSeconds = 30,
  }) async {
    final response = await _channel.invokeMapMethod<String, dynamic>(
      'pay',
      <String, dynamic>{
        'upiUri': upiUri,
        'targetAppId': targetAppId,
        'timeoutSeconds': timeoutSeconds,
      },
    );
    return response ?? const <String, dynamic>{};
  }
}
