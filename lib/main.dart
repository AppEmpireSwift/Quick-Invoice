import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:apphud_helper/apphud_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:quick_invoice/app/ui/root/quick_invoice_main.page.dart';
import 'app/app.dart';
import 'app/ui/onboarding/quick_invoice_onboarding.page.dart';
import 'app/ui/quick_invoice_splash.page.dart';
import 'core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QICore.init(
    config: QIConfig(
      appName: 'Quick Invoice',
      figmaDesignSize: Size(375, 812),
      appId: '6757950869',
      appHudKey: 'app_ZbRW8co8oEWvQJJUMvgRo3bNCWGCQh',
      supportEmail: 'hollyreeves@murermesterdennisbotker.com',
      supportForm: '',
    ),
    home: QuickInvoiceMainPage(),

    ///MainPage(),
    splash: QuickInvoiceSplashPage(),
    onBoarding: QuickInvoiceOnBoardingPage(),
  );
  ApphudHelper.configure(
    ApphudHelperConfig(
      apiKey: QICore.config.appHudKey,
      productTexts: ProductTexts(),
      dialogs: DialogTexts(),
      fallbacks: CommonFallbackTexts(restoreButtonText: 'Restore'),
      mainPaywallSettings: MainPaywallSettings(),
      onBoardingPaywallSettings: OnBoardingPaywallSettings(),
    ),
    helperType: HelperType.fallbackBased, //TODO:
  );
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) {
        return const QuickInvoiceApp();
      },
    ),
  );
}

//TODO: fix bundle id
