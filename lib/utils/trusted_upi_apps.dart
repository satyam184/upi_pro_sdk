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
    TrustedUpiApp(
      displayName: 'Mobikwik',
      androidPackage: 'com.mobikwik_new',
      iosScheme: 'mobikwik',
      rank: 7,
    ),
    TrustedUpiApp(
      displayName: 'Freecharge',
      androidPackage: 'com.freecharge.android',
      iosScheme: 'freecharge',
      rank: 8,
    ),
    TrustedUpiApp(
      displayName: 'Airtel Thanks',
      androidPackage: 'com.myairtelapp',
      iosScheme: 'myairtel',
      rank: 9,
    ),
    TrustedUpiApp(
      displayName: 'Truecaller Pay',
      androidPackage: 'com.truecaller',
      iosScheme: 'truecaller',
      rank: 10,
    ),
    TrustedUpiApp(
      displayName: 'WhatsApp Pay',
      androidPackage: 'com.whatsapp',
      iosScheme: 'whatsapp',
      rank: 11,
    ),
    TrustedUpiApp(
      displayName: 'Mi Pay',
      androidPackage: 'com.mipay.in.wallet',
      rank: 12,
    ),
    TrustedUpiApp(
      displayName: 'PayZapp',
      androidPackage: 'com.enstage.wibmo.hdfc',
      rank: 13,
    ),
    TrustedUpiApp(
      displayName: 'iMobile (ICICI)',
      androidPackage: 'com.csam.icici.bank.imobile',
      iosScheme: 'imobileapp',
      rank: 14,
    ),
    TrustedUpiApp(
      displayName: 'SBI Pay',
      androidPackage: 'com.sbi.upi',
      rank: 15,
    ),
    TrustedUpiApp(
      displayName: 'Axis Pay',
      androidPackage: 'com.upi.axispay',
      rank: 16,
    ),
    TrustedUpiApp(
      displayName: 'HDFC Bank',
      androidPackage: 'com.snapwork.hdfc',
      iosScheme: 'hdfcnewbb',
      rank: 17,
    ),
    TrustedUpiApp(
      displayName: 'MyJio',
      androidPackage: 'com.jio.myjio',
      iosScheme: 'myJio',
      rank: 18,
    ),
    TrustedUpiApp(
      displayName: 'FamPay',
      androidPackage: 'com.fampay.in',
      iosScheme: 'in.fampay.app',
      rank: 19,
    ),
    TrustedUpiApp(
      displayName: 'LazyPay',
      androidPackage: 'com.citrus.citruspay',
      iosScheme: 'www.citruspay.com',
      rank: 20,
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
