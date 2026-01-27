import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DeviceType { iphoneSe, iphoneBase, ipad }

const _aspectRatioTolerance = 0.01;

//ipad mini
const _ipadMinWidth = 744;

class QuickInvoiceUIHelper {
  final BuildContext context;
  final MediaQueryData _mediaQuery;

  QuickInvoiceUIHelper._internal(this.context) : _mediaQuery = MediaQuery.of(context) {
    switch (deviceType) {
      case DeviceType.iphoneSe:
      case DeviceType.iphoneBase:
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      case DeviceType.ipad:
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
    }
  }

  static QuickInvoiceUIHelper of(BuildContext context) => QuickInvoiceUIHelper._internal(context);

  double get screenWidth => _mediaQuery.size.width;

  double get screenHeight => _mediaQuery.size.height;

  double get shortestSide => _mediaQuery.size.shortestSide;

  double get longestSide => _mediaQuery.size.longestSide;

  Orientation get orientation => _mediaQuery.orientation;

  double get aspectRatio => _mediaQuery.size.aspectRatio;

  DeviceType get deviceType {
    final width = shortestSide;

    if (width >= _ipadMinWidth) {
      return DeviceType.ipad;
    }

    if (isAspectRatio9by16) {
      return DeviceType.iphoneSe;
    }

    return DeviceType.iphoneBase;
  }

  bool get isAspectRatio9by16 {
    const targetRatio = 9 / 16;

    return (aspectRatio - targetRatio).abs() <= _aspectRatioTolerance;
  }

  bool get isIpad => deviceType == DeviceType.ipad;
  bool get isIphoneSe => deviceType == DeviceType.iphoneSe;
  bool get isBaseIphone => deviceType == DeviceType.iphoneBase;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;
}
