import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/upi_sdk_exception.dart';
import '../models/upi_analytics_hooks.dart';
import '../models/upi_app.dart';
import '../models/upi_failure_type.dart';
import '../models/upi_payment_request.dart';
import '../models/upi_response.dart';
import '../parser/upi_response_parser.dart';
import '../ui/upi_app_picker_sheet.dart';
import '../utils/trusted_upi_apps.dart';
import '../utils/upi_uri_builder.dart';
import '../utils/upi_validators.dart';
import 'platform/upi_platform_channel.dart';

class UpiProSdk {
  UpiProSdk({
    UpiPlatformChannel? platformChannel,
    UpiResponseParser? responseParser,
    UpiUriBuilder? uriBuilder,
    this.analyticsHooks = const UpiAnalyticsHooks(),
  })  : _platformChannel = platformChannel ?? UpiPlatformChannel(),
        _responseParser = responseParser ?? const UpiResponseParser(),
        _uriBuilder = uriBuilder ?? const UpiUriBuilder();

  final UpiPlatformChannel _platformChannel;
  final UpiResponseParser _responseParser;
  final UpiUriBuilder _uriBuilder;
  final UpiAnalyticsHooks analyticsHooks;

  Future<List<UpiApp>> getInstalledApps() async {
    final rawApps = await _platformChannel.getInstalledApps();
    final verified = rawApps
        .map(_mapToUpiApp)
        .where((app) => app.isVerified)
        .toList(growable: false);
    verified.sort((a, b) => a.rank.compareTo(b.rank));
    return verified;
  }

  Future<UpiResponse> pay(
    UpiPaymentRequest request, {
    UpiApp? app,
    int timeoutSeconds = 30,
  }) async {
    UpiValidators.validateRequest(request);
    analyticsHooks.onPaymentInitiated?.call(request);

    final selectedApp = app ?? await _resolveDefaultApp();
    if (selectedApp == null && Platform.isIOS) {
      throw const NoUpiAppFoundException();
    }

    final upiUri = _uriBuilder.build(request).toString();
    analyticsHooks.onAppLaunched?.call(selectedApp?.identifier ?? 'chooser');

    final nativeResponse = await _invokePay(
      upiUri: upiUri,
      targetAppId: _targetIdentifier(selectedApp),
      timeoutSeconds: timeoutSeconds,
    );

    final parsed = _responseParser.parse(nativeResponse);
    analyticsHooks.onResponseReceived?.call(parsed);

    if (parsed.failureType == UpiFailureType.timeout) {
      analyticsHooks.onTimeout?.call();
      throw const TimeoutException();
    }
    if (parsed.failureType == UpiFailureType.userCancelled) {
      throw const PaymentCancelledException();
    }
    if (parsed.failureType == UpiFailureType.appNotResponding) {
      throw const AppNotRespondingException();
    }
    return parsed;
  }

  Future<UpiResponse> payWithAppPicker(
    BuildContext context,
    UpiPaymentRequest request, {
    int timeoutSeconds = 30,
    String title = 'Select UPI App',
    Color? backgroundColor,
  }) async {
    final apps = await getInstalledApps();
    if (apps.isEmpty) {
      throw const NoUpiAppFoundException();
    }
    if (!context.mounted) {
      throw const PaymentCancelledException(details: 'Context no longer mounted.');
    }
    final selected = await showUpiAppPickerBottomSheet(
      context,
      apps: apps,
      title: title,
      backgroundColor: backgroundColor,
    );
    if (selected == null) {
      throw const PaymentCancelledException(details: 'No UPI app selected.');
    }
    return pay(request, app: selected, timeoutSeconds: timeoutSeconds);
  }

  Future<Map<String, dynamic>> _invokePay({
    required String upiUri,
    required String? targetAppId,
    required int timeoutSeconds,
  }) async {
    try {
      return await _platformChannel.pay(
        upiUri: upiUri,
        targetAppId: targetAppId,
        timeoutSeconds: timeoutSeconds,
      );
    } on PlatformException catch (e) {
      analyticsHooks.onFailure?.call(e);
      if (e.code == 'no_upi_app_found') {
        throw const NoUpiAppFoundException();
      }
      if (e.code == 'invalid_request') {
        throw UpiSdkException(
          e.message ?? 'Invalid payment request.',
          code: e.code,
          details: e.details,
        );
      }
      throw UpiSdkException(
        e.message ?? 'Platform payment error.',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      analyticsHooks.onFailure?.call(e);
      rethrow;
    }
  }

  UpiApp _mapToUpiApp(Map<String, dynamic> raw) {
    final packageName = _safeString(raw['packageName']);
    final scheme = _safeString(raw['scheme']);
    final trusted = TrustedUpiApps.byAndroidPackage(packageName) ??
        TrustedUpiApps.byIosScheme(scheme);

    return UpiApp(
      name: _safeString(raw['name']) ?? trusted?.displayName ?? 'UPI App',
      packageName: packageName,
      scheme: scheme,
      icon: _decodeIcon(raw['icon']),
      isVerified: trusted != null,
      rank: trusted?.rank ?? 999,
    );
  }

  Future<UpiApp?> _resolveDefaultApp() async {
    final apps = await getInstalledApps();
    if (apps.isEmpty) {
      return null;
    }
    return apps.first;
  }

  String? _targetIdentifier(UpiApp? app) {
    if (app == null) {
      return null;
    }
    return Platform.isAndroid ? app.packageName : app.scheme;
  }

  String? _safeString(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  Uint8List? _decodeIcon(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }
}
