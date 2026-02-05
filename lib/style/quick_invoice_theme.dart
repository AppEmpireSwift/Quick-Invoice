import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'quick_invoice_style.dart';

ThemeData quickInvoiceAppThemeBuilder(BuildContext context) => ThemeData(
  textTheme: Typography.blackCupertino.apply(bodyColor: QuickInvoiceColorStyles.black),
  colorScheme: ColorScheme.fromSeed(
    seedColor: QuickInvoiceColorStyles.primary,
    brightness: Brightness.light,
  ),
  iconTheme: const IconThemeData(color: QuickInvoiceThemeColors.iconColor),
  scaffoldBackgroundColor: QuickInvoiceThemeColors.pageBackground,
  appBarTheme: AppBarTheme(
    actionsPadding: EdgeInsets.symmetric(horizontal: 16).r,
    centerTitle: true,
    backgroundColor: QuickInvoiceThemeColors.appBarBackground,
    foregroundColor: QuickInvoiceThemeColors.appBarForeground,
    titleTextStyle: QuickInvoiceThemeTextStyles.appBarTitle,
    iconTheme: const IconThemeData(color: QuickInvoiceThemeColors.iconColor),
    actionsIconTheme: const IconThemeData(color: QuickInvoiceThemeColors.actionIconColor),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateColor.resolveWith((state) {
        if (state.contains(WidgetState.disabled)) {
          return QuickInvoiceThemeColors.filledButtonDisalbed;
        }
        return QuickInvoiceThemeColors.filledButton;
      }),
      textStyle: WidgetStateProperty.resolveWith<TextStyle>((state) {
        if (state.contains(WidgetState.disabled)) {
          return QuickInvoiceThemeTextStyles.filledButttonDisabledText;
        }
        return QuickInvoiceThemeTextStyles.filledButttonText;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((state) {
        if (state.contains(WidgetState.disabled)) {
          return QuickInvoiceThemeColors.filledButtonDisableForeground;
        }
        return QuickInvoiceThemeColors.filledButtonForeground;
      }),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.spMin)),
      ),
      minimumSize: WidgetStateProperty.all(Size(162.r, 56.spMin)),
      maximumSize: WidgetStateProperty.all(Size(375.r, 56.spMin)),
    ),
  ),
  cupertinoOverrideTheme: const CupertinoThemeData(
    barBackgroundColor: QuickInvoiceThemeColors.pageBackground,
    scaffoldBackgroundColor: QuickInvoiceThemeColors.pageBackground,
    primaryColor: QuickInvoiceColorStyles.primary,
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    border: InputBorder.none,
    floatingLabelBehavior: FloatingLabelBehavior.never,
  ),
);

CupertinoThemeData quickInvoiceCupertinoThemeBuilder(BuildContext context) =>
    CupertinoThemeData(
      primaryColor: QuickInvoiceColorStyles.primary,
      scaffoldBackgroundColor: QuickInvoiceColorStyles.bgSecondary,
      barBackgroundColor: QuickInvoiceColorStyles.bgSecondary,
      brightness: Brightness.light,
      textTheme: CupertinoTextThemeData(
        primaryColor: QuickInvoiceColorStyles.primary,
        textStyle: TextStyle(color: QuickInvoiceColorStyles.primaryTxt),
      ),
    );
