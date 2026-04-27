import 'dart:typed_data';

import 'package:meta/meta.dart';

@immutable
class UpiApp {
  const UpiApp({
    required this.name,
    this.packageName,
    this.scheme,
    this.icon,
    required this.isVerified,
    this.rank = 999,
  });

  final String name;
  final String? packageName;
  final String? scheme;
  final Uint8List? icon;
  final bool isVerified;
  final int rank;

  String get identifier => packageName ?? scheme ?? name;

  UpiApp copyWith({
    String? name,
    String? packageName,
    String? scheme,
    Uint8List? icon,
    bool? isVerified,
    int? rank,
  }) {
    return UpiApp(
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      scheme: scheme ?? this.scheme,
      icon: icon ?? this.icon,
      isVerified: isVerified ?? this.isVerified,
      rank: rank ?? this.rank,
    );
  }

  @override
  String toString() {
    return 'UpiApp(name: $name, packageName: $packageName, '
        'scheme: $scheme, isVerified: $isVerified)';
  }
}
