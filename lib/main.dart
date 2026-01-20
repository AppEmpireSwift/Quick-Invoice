import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:apphud_helper/apphud_helper.dart';

import 'app/app.dart';
import 'app/ui/onboarding/onboarding.page.dart';
import 'app/ui/root/main.page.dart';
import 'app/ui/splash.page.dart';
import 'core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Core.init(
    config: CommonConfig(
      appName: 'Quick Invoice',
      figmaDesignSize: Size(375, 812),
      appId: '111111111',
      appHudKey: 'app_HorEUWWedWd1V683fWnwZwZFLfvZEr',
      supportEmail: 'support@email.com',
      supportForm: 'https://forms.gle/EH8YUddXBzfSxVR26',
    ),
    home: MainPage(),
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
    helperType: HelperType.fallbackBased,
  );
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) {
        return const WASkeleton();
      },
    ),
  );
}
