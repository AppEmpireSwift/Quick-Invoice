import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:apphud_helper/apphud_helper.dart';
import 'package:flutter/cupertino.dart';
import 'app/ui/premium/main_paywall.page.dart';
import 'app/app.dart';
import 'app/ui/onboarding/onboarding.page.dart';
import 'app/ui/splash.page.dart';
import 'core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) {
        return const QuickInvoiceApp();
      },
    ),
  );
}

Future<void> init() async {
  await Core.init(
    config: CommonConfig(
      appName: 'Quick Invoice',
      figmaDesignSize: Size(375, 812),
      appId: '6757950869',
      appHudKey: 'app_ZbRW8co8oEWvQJJUMvgRo3bNCWGCQh',
      supportEmail: 'hollyreeves@murermesterdennisbotker.com',
      supportForm: '',
    ),
    home: MainPaywallPage(),

    ///MainPage(),
    splash: SplashPage(),
    onBoarding: OnBoardingPage(),
  );
  ApphudHelper.configure(
    ApphudHelperConfig(
      apiKey: Core.config.appHudKey,
      productTexts: ProductTexts(),
      dialogs: DialogTexts(),
      fallbacks: CommonFallbackTexts(restoreButtonText: 'Restore'),
      mainPaywallSettings: MainPaywallSettings(),
      onBoardingPaywallSettings: OnBoardingPaywallSettings(),
    ),
    helperType: HelperType.fallbackBased, //TODO:
  );
}
