import Flutter
import UIKit

public final class UpiProSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "upi_pro_sdk/methods",
      binaryMessenger: registrar.messenger()
    )
    let instance = UpiProSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getInstalledApps":
      result(getInstalledUpiApps())
    case "pay":
      handlePay(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getInstalledUpiApps() -> [[String: Any?]] {
    let knownSchemes: [(name: String, scheme: String)] = [
      ("PhonePe", "phonepe"),
      ("Google Pay", "gpay"),
      ("Paytm", "paytmmp"),
      ("BHIM", "bhim")
    ]

    var apps: [[String: Any?]] = []
    for app in knownSchemes {
      guard let url = URL(string: "\(app.scheme)://") else {
        continue
      }
      if UIApplication.shared.canOpenURL(url) {
        apps.append([
          "name": app.name,
          "scheme": app.scheme
        ])
      }
    }
    return apps
  }

  private func handlePay(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let args = call.arguments as? [String: Any],
      let upiUri = args["upiUri"] as? String,
      !upiUri.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      result(
        FlutterError(
          code: "invalid_request",
          message: "UPI URI is required.",
          details: nil
        )
      )
      return
    }

    guard var components = URLComponents(string: upiUri) else {
      result(
        FlutterError(
          code: "invalid_request",
          message: "Invalid UPI URI.",
          details: nil
        )
      )
      return
    }

    if let targetAppId = args["targetAppId"] as? String, !targetAppId.isEmpty {
      components.scheme = targetAppId
    }

    guard let launchUrl = components.url else {
      result(
        FlutterError(
          code: "invalid_request",
          message: "Unable to construct launch URL.",
          details: nil
        )
      )
      return
    }

    if !UIApplication.shared.canOpenURL(launchUrl) {
      result(
        FlutterError(
          code: "no_upi_app_found",
          message: "No compatible UPI app found.",
          details: nil
        )
      )
      return
    }

    UIApplication.shared.open(launchUrl, options: [:]) { success in
      if success {
        result([
          "rawResponse": "",
          "statusHint": "unknown",
          "failureType": "app_not_responding"
        ])
      } else {
        result(
          FlutterError(
            code: "launch_failed",
            message: "Unable to launch selected UPI app.",
            details: nil
          )
        )
      }
    }
  }
}
