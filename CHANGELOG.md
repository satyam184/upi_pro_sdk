# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/) conventions.

---

## [0.1.0] - 2025-04-28

### Added
- Initial public release 🎉
- `UpiProClient` — main entry point for all UPI operations
- `initiatePayment()` — UPI intent-based payment flow
- `showAppChooser()` — bottom sheet multi-app UPI launcher
- `validateVpa()` — Virtual Payment Address validation
- `pollPaymentStatus()` — configurable polling with retry logic
- `getInstalledUpiApps()` — detect all installed UPI apps on device
- `UpiPaymentRequest` model with full UPI deep link parameter support
- `UpiPaymentResponse` model with typed status enum
- `UpiException` with error codes for structured error handling
- `VpaValidationResult` model
- Android `<queries>` manifest support for UPI intent resolution
- iOS `LSApplicationQueriesSchemes` support
- Full unit test suite with `MockUpiProClient`
- MIT License

---

## [Unreleased]

### Planned
- Collect flow / payment request links
- QR Code generation for static & dynamic UPI QR
- Subscription / recurring payment support
- Webhook signature verification utility
