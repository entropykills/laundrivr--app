import 'package:flutter/material.dart';

@immutable
class LaundrivrTheme extends ThemeExtension<LaundrivrTheme> {
  const LaundrivrTheme(
      {required this.opaqueBackgroundColor,
      required this.primaryBrightTextColor,
      required this.primaryTextStyle,
      required this.secondaryOpaqueBackgroundColor,
      required this.selectedIconColor,
      required this.unselectedIconColor,
      required this.goldenTextColor,
      required this.tertiaryOpaqueBackgroundColor,
      required this.bottomNavBarBackgroundColor,
      required this.brightBadgeBackgroundColor,
      required this.pricingGreen});

  final Color? opaqueBackgroundColor;
  final Color? secondaryOpaqueBackgroundColor;
  final Color? primaryBrightTextColor;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final TextStyle? primaryTextStyle;
  final Color? goldenTextColor;
  final Color? tertiaryOpaqueBackgroundColor;
  final Color? bottomNavBarBackgroundColor;
  final Color? brightBadgeBackgroundColor;
  final Color? pricingGreen;

  @override
  LaundrivrTheme copyWith(
      {Color? opaqueBackgroundColor,
      Color? primaryBrightTextColor,
      TextStyle? primaryTextStyle,
      Color? secondaryOpaqueBackgroundColor,
      Color? selectedIconColor,
      Color? unselectedIconColor,
      Color? goldenTextColor,
      Color? tertiaryOpaqueBackgroundColor,
      Color? bottomNavBarBackgroundColor,
      Color? brightBadgeBackgroundColor,
      Color? pricingGreen}) {
    return LaundrivrTheme(
      opaqueBackgroundColor:
          opaqueBackgroundColor ?? this.opaqueBackgroundColor,
      primaryBrightTextColor:
          primaryBrightTextColor ?? this.primaryBrightTextColor,
      primaryTextStyle: primaryTextStyle ?? this.primaryTextStyle,
      secondaryOpaqueBackgroundColor:
          secondaryOpaqueBackgroundColor ?? this.secondaryOpaqueBackgroundColor,
      selectedIconColor: selectedIconColor ?? this.selectedIconColor,
      unselectedIconColor: unselectedIconColor ?? this.unselectedIconColor,
      goldenTextColor: goldenTextColor ?? this.goldenTextColor,
      tertiaryOpaqueBackgroundColor:
          tertiaryOpaqueBackgroundColor ?? this.tertiaryOpaqueBackgroundColor,
      bottomNavBarBackgroundColor:
          bottomNavBarBackgroundColor ?? this.bottomNavBarBackgroundColor,
      brightBadgeBackgroundColor:
          brightBadgeBackgroundColor ?? this.brightBadgeBackgroundColor,
      pricingGreen: pricingGreen ?? this.pricingGreen,
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
      selectedIconColor:
          Color.lerp(selectedIconColor, other.selectedIconColor, t),
      unselectedIconColor:
          Color.lerp(unselectedIconColor, other.unselectedIconColor, t),
      goldenTextColor: Color.lerp(goldenTextColor, other.goldenTextColor, t),
      tertiaryOpaqueBackgroundColor: Color.lerp(tertiaryOpaqueBackgroundColor,
          other.tertiaryOpaqueBackgroundColor, t),
      bottomNavBarBackgroundColor: Color.lerp(
          bottomNavBarBackgroundColor, other.bottomNavBarBackgroundColor, t),
      brightBadgeBackgroundColor: Color.lerp(
          brightBadgeBackgroundColor, other.brightBadgeBackgroundColor, t),
      pricingGreen: Color.lerp(pricingGreen, other.pricingGreen, t),
    );
  }

  // Optional
  @override
  String toString() => 'LaundrivrTheme';
}
