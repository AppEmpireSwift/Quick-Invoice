import 'dart:ui';

import 'package:flutter/material.dart';

class QuickInvoiceColorStyles {
  static const primary = Color(0xFF007AFF);
  static const primaryWithOpacity = Color(0x26007AFF);
  static const green = Color(0xFF34C759);
  static const greenWithOpacity = Color(0x3334C759);
  static const bgSecondary = Color(0xFFF2F2F7);
  static const primaryTxt = Color(0xFF1C1C1E);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const pink = Color(0xFFFF2D55);
  static const pinkWithOpacity = Color(0x33FF2D55);
  static const orange = Color(0xFFFF9500);
  static const orangeWithOpacity = Color(0x33FF9500);
  static const cyan = Color(0xFF32ADE6);
  static const cyanWithOpacity = Color(0x3332ADE6);
  static const yellow = Color(0xFFFFCC00);
  static const yellowWithOpacity = Color(0x33FFCC00);

  static const yellowDark = Color(0xFFFFD60A);

  static const color1 = Color(0xFFE7F3FF);
  static const color2 = Color(0x99FFFFFF);
  static const labelsSecondaryDark = Color(0x99EBEBF5);
  static const color4 = Color(0x4DEBEBF5);
  static const color5 = Color(0x29EBEBF5);
  static const secondary = Color(0xFF8E8E93);
  static const labelsTertiary = Color(0x4D3C3C43);
  static const color8 = Color(0x2E3C3C43);
  static const fillsTertiary = Color(0x1F767680);

  static const separator = Color(0xFFC6C6C8);
  static const searchBg = Color(0xFFE5E5EA);

  static const gray2Dark = Color(0xFF636366);
}

class QuickInvoiceThemeColors {
  static const splashBackground = QuickInvoiceColorStyles.primary;
  static const pageBackground = QuickInvoiceColorStyles.bgSecondary;
  static const appBarBackground = QuickInvoiceColorStyles.bgSecondary;
  static const appBarForeground = QuickInvoiceColorStyles.primaryTxt;

  static const filledButton = QuickInvoiceColorStyles.primary;
  static const filledButtonDisalbed = QuickInvoiceColorStyles.fillsTertiary;
  static const filledButtonForeground = QuickInvoiceColorStyles.white;
  static const filledButtonText = QuickInvoiceColorStyles.white;
  static const filledButtonDisableText = QuickInvoiceColorStyles.labelsTertiary;
  static const filledButtonDisableForeground = QuickInvoiceColorStyles.labelsTertiary;
  static const textFieldBackground = QuickInvoiceColorStyles.white;
  static const textFieldInput = QuickInvoiceColorStyles.primary;

  static const iconColor = QuickInvoiceColorStyles.primary;
  static const actionIconColor = QuickInvoiceColorStyles.primary;
  static const deleteColor = QuickInvoiceColorStyles.pink;
}
