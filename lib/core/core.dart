import 'package:flutter/widgets.dart';
import 'package:quick_invoice/core/services/quick_invoice_boarding.helper.dart';
import 'entities/qi_config.dart';
export 'utils.dart';
export 'services/quick_invoice_boarding.helper.dart';
export 'services/qi_share.helper.dart';
export 'entities/qi_config.dart';

export 'ui/quick_invoice_loading.dart';
export 'ui/quick_invoice_root_wrapper.dart';
export 'ui/quick_invoice_onboarding_wrapper.dart';

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
    await QIBoardingHelper.init();
    _initialized = true;
  }
}
