import 'package:flutter/material.dart';

@immutable
class LaundrivrTheme extends ThemeExtension<LaundrivrTheme> {
  const LaundrivrTheme({
    required this.opaqueBackgroundColor,
    required this.primaryBrightTextColor,
    required this.primaryTextStyle,
    required this.secondaryOpaqueBackgroundColor,
    required this.selectedIconColor,
    required this.unselectedIconColor,
    required this.goldenTextColor,
    required this.tertiaryOpaqueBackgroundColor,
    required this.bottomNavBarBackgroundColor,
    required this.brightBadgeBackgroundColor,
    required this.pricingGreen,
    required this.backButtonBackgroundColor,
    required this.pinCodeInactiveColor,
    required this.pinCodeActiveValidColor,
    required this.pinCodeActiveInvalidColor,
  });

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
  final Color? backButtonBackgroundColor;
  final Color? pinCodeInactiveColor;
  final Color? pinCodeActiveValidColor;
  final Color? pinCodeActiveInvalidColor;

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
      Color? pricingGreen,
      Color? backButtonBackgroundColor,
      Color? pinCodeInactiveColor,
      Color? pinCodeActiveValidColor,
      Color? pinCodeActiveInvalidColor}) {
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
      backButtonBackgroundColor:
          backButtonBackgroundColor ?? this.backButtonBackgroundColor,
      pinCodeInactiveColor: pinCodeInactiveColor ?? this.pinCodeInactiveColor,
      pinCodeActiveValidColor:
          pinCodeActiveValidColor ?? this.pinCodeActiveValidColor,
      pinCodeActiveInvalidColor:
          pinCodeActiveInvalidColor ?? this.pinCodeActiveInvalidColor,
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
      backButtonBackgroundColor: Color.lerp(
          backButtonBackgroundColor, other.backButtonBackgroundColor, t),
      pinCodeInactiveColor:
          Color.lerp(pinCodeInactiveColor, other.pinCodeInactiveColor, t),
      pinCodeActiveValidColor:
          Color.lerp(pinCodeActiveValidColor, other.pinCodeActiveValidColor, t),
      pinCodeActiveInvalidColor: Color.lerp(
          pinCodeActiveInvalidColor, other.pinCodeActiveInvalidColor, t),
    );
  }

  // Optional
  @override
  String toString() => 'LaundrivrTheme';
}
