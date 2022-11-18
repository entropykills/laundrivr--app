import 'package:flutter/material.dart';

@immutable
class LaundrivrTheme extends ThemeExtension<LaundrivrTheme> {
  const LaundrivrTheme(
      {required this.opaqueBackgroundColor,
      required this.primaryBrightTextColor,
      required this.primaryTextStyle,
      required this.secondaryOpaqueBackgroundColor});

  final Color? opaqueBackgroundColor;
  final Color? secondaryOpaqueBackgroundColor;
  final Color? primaryBrightTextColor;
  final TextStyle? primaryTextStyle;

  @override
  LaundrivrTheme copyWith(
      {Color? opaqueBackgroundColor,
      Color? primaryBrightTextColor,
      TextStyle? primaryTextStyle}) {
    return LaundrivrTheme(
      opaqueBackgroundColor:
          opaqueBackgroundColor ?? this.opaqueBackgroundColor,
      primaryBrightTextColor:
          primaryBrightTextColor ?? this.primaryBrightTextColor,
      primaryTextStyle: primaryTextStyle ?? this.primaryTextStyle,
      secondaryOpaqueBackgroundColor:
          secondaryOpaqueBackgroundColor ?? this.secondaryOpaqueBackgroundColor,
    );
  }

  @override
  LaundrivrTheme lerp(ThemeExtension<LaundrivrTheme>? other, double t) {
    if (other is! LaundrivrTheme) {
      return this;
    }
    return LaundrivrTheme(
      opaqueBackgroundColor:
          Color.lerp(opaqueBackgroundColor, other.opaqueBackgroundColor, t),
      secondaryOpaqueBackgroundColor: Color.lerp(secondaryOpaqueBackgroundColor,
          other.secondaryOpaqueBackgroundColor, t),
      primaryBrightTextColor:
          Color.lerp(primaryBrightTextColor, other.primaryBrightTextColor, t),
      primaryTextStyle:
          TextStyle.lerp(primaryTextStyle, other.primaryTextStyle, t),
    );
  }

  // Optional
  @override
  String toString() => 'LaundrivrTheme';
}
