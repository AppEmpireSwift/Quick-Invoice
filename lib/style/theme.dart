import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'style.dart';

appThemeBuilder(BuildContext context) => ThemeData(
  textTheme: Typography.blackCupertino.apply(bodyColor: ColorStyles.black),
  colorScheme: ColorScheme.fromSeed(
    seedColor: ColorStyles.primary,
    brightness: Brightness.light,
  ),
  iconTheme: const IconThemeData(color: ThemeColors.iconColor),
  scaffoldBackgroundColor: ThemeColors.pageBackground,
  appBarTheme: AppBarTheme(
    actionsPadding: EdgeInsets.symmetric(horizontal: 16).r,
    centerTitle: true,
    backgroundColor: ThemeColors.appBarBackground,
    foregroundColor: ThemeColors.appBarForeground,
    titleTextStyle: ThemeTextStyles.appBarTitle,
    iconTheme: const IconThemeData(color: ThemeColors.iconColor),
    actionsIconTheme: const IconThemeData(color: ThemeColors.actionIconColor),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateColor.resolveWith((state) {
        if (state.contains(WidgetState.disabled)) {
          return ThemeColors.filledButtonDisalbed;
        }
        return ThemeColors.filledButton;
      }),
      textStyle: WidgetStateProperty.resolveWith<TextStyle>((state) {
        if (state.contains(WidgetState.disabled)) {
          return ThemeTextStyles.filledButttonDisabledText;
        }
        return ThemeTextStyles.filledButttonText;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((state) {
        if (state.contains(WidgetState.disabled)) {
          return ThemeColors.filledButtonDisableForeground;
        }
        return ThemeColors.filledButtonForeground;
      }),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.spMin)),
      ),
      minimumSize: WidgetStateProperty.all(Size(162.r, 56.spMin)),
      maximumSize: WidgetStateProperty.all(Size(375.r, 56.spMin)),
    ),
  ),
  cupertinoOverrideTheme: const CupertinoThemeData(
    barBackgroundColor: ThemeColors.pageBackground,
    scaffoldBackgroundColor: ThemeColors.pageBackground,
    primaryColor: ColorStyles.primary,
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    border: InputBorder.none,
    floatingLabelBehavior: FloatingLabelBehavior.never,
  ),
);

CupertinoThemeData cupertinoThemeBuilder(BuildContext context) => CupertinoThemeData(
  primaryColor: ColorStyles.primary,
  scaffoldBackgroundColor: ColorStyles.bgSecondary,
  barBackgroundColor: ColorStyles.bgSecondary,
  brightness: Brightness.light,
  textTheme: CupertinoTextThemeData(
    primaryColor: ColorStyles.primary,
    textStyle: TextStyle(color: ColorStyles.primaryTxt),
  ),
);
