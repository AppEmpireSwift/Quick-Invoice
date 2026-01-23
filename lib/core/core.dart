import 'package:flutter/widgets.dart';

import 'entities/config.dart';
import 'services/boarding.helper.dart';
import 'services/path.dart';

export 'utils.dart';
export 'services/boarding.helper.dart';
export 'services/path.dart';
export 'services/share.helper.dart';
export 'entities/config.dart';

export 'ui/launch.wrapper.dart';
export 'ui/root.wrapper.dart';
export 'ui/onboarding.wrapper.dart';

class QICore {
  static late final QIConfig config;

  static bool _initialized = false;

  static late final Widget homePage;

  static late final Widget splashPage;

  static late final Widget boardingPage;

  static Future<void> init({
    required QIConfig config,
    required Widget home,
    required Widget splash,
    required Widget onBoarding,
  }) async {
    if (_initialized) return;
    QICore.config = config;
    QICore.homePage = home;
    QICore.splashPage = splash;
    QICore.boardingPage = onBoarding;
    await initDirPath();
    await QIBoardingHelper.init();
    _initialized = true;
  }
}
