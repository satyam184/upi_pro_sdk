import 'package:meta/meta.dart';

@immutable
class TrustedUpiApp {
  const TrustedUpiApp({
    required this.displayName,
    this.androidPackage,
    this.iosScheme,
    required this.rank,
  });

  final String displayName;
  final String? androidPackage;
  final String? iosScheme;
  final int rank;
}

class TrustedUpiApps {
  static const List<TrustedUpiApp> all = <TrustedUpiApp>[
    TrustedUpiApp(
      displayName: 'Google Pay',
      androidPackage: 'com.google.android.apps.nbu.paisa.user',
      iosScheme: 'tez',
      rank: 1,
    ),
    TrustedUpiApp(
      displayName: 'PhonePe',
      androidPackage: 'com.phonepe.app',
      iosScheme: 'phonepe',
      rank: 2,
    ),
    TrustedUpiApp(
      displayName: 'Paytm',
      androidPackage: 'net.one97.paytm',
      iosScheme: 'paytmmp',
      rank: 3,
    ),
    TrustedUpiApp(
      displayName: 'BHIM',
      androidPackage: 'in.org.npci.upiapp',
      iosScheme: 'bhim',
      rank: 4,
    ),
    TrustedUpiApp(
      displayName: 'Amazon Pay',
      androidPackage: 'in.amazon.mShop.android.shopping',
      iosScheme: 'amazonpay',
      rank: 5,
    ),
    TrustedUpiApp(
      displayName: 'CRED',
      androidPackage: 'com.dreamplug.androidapp',
      iosScheme: 'credpay',
      rank: 6,
    ),
  ];

  static TrustedUpiApp? byAndroidPackage(String? packageName) {
    if (packageName == null) {
      return null;
    }
    return all
        .where((app) => app.androidPackage == packageName)
        .cast<TrustedUpiApp?>()
        .firstWhere((app) => app != null, orElse: () => null);
  }

  static TrustedUpiApp? byIosScheme(String? scheme) {
    if (scheme == null) {
      return null;
    }
    return all
        .where((app) => app.iosScheme == scheme)
        .cast<TrustedUpiApp?>()
        .firstWhere((app) => app != null, orElse: () => null);
  }
}
