import 'package:apphud_helper/apphud_helper.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_wa_skeleton/core/services/ui.helper.dart';
import 'package:flutter_wa_skeleton/core/ui/home_indicator_space.dart';

import '../../../core/core.dart';
import '../../../gen/assets.gen.dart';
import '../../../style/style.dart';
import '../../app.dart';
import '../common/filled_button.dart';

class MainPaywallPage extends StatelessWidget {
  const MainPaywallPage({super.key});

  static Route route() => MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => MainPaywallPage(),
  );

  @override
  Widget build(BuildContext context) {
    String bg;
    switch (uiHelper.deviceType) {
      case AppleDeviceType.iphoneSe:
        bg = Assets.images.premium.paywallSe.path;
      case AppleDeviceType.iphoneBase:
        bg = Assets.images.premium.paywall.path;
      case AppleDeviceType.ipad:
        if (uiHelper.isLandscape) {
          bg = Assets.images.premium.paywallAlbum.path;
        } else {
          bg = Assets.images.premium.paywallIpad.path;
        }
    }
    return PaywallWrapper(
      onSkipPaywallCallback: () {
        //todo your router for stage 2
        Navigator.pop(context);
      },
      onSuccessPurchaseCallback: () {
        //todo your router for stage 2
        Navigator.pop(context, true);
      },
      paywallType: PaywallType.main,
      paywallPage: Scaffold(
        backgroundColor: ColorStyles.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: Image.asset(bg, fit: BoxFit.cover)),

            Positioned(
              // top: 10,
              right: 10,
              child: SafeArea(
                child: PaywallCloseButton(
                  buttonBuilder:
                      (onClose) => CloseButton(
                        onPressed: onClose,
                        color: ColorStyles.primaryTxt,
                      ),
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16).r,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PaywallActiveProductInfo(
                      infoBuilder: (
                        String activeProductInfo,
                        String? limitedText,
                        _,
                      ) {
                        return Text(
                          activeProductInfo,
                          textAlign: TextAlign.center,
                          style: TextStyles.footnoteRegular,
                        );
                      },
                    ),
                    PaywallTitle(
                      titleBuilder: (String title) {
                        return Text(
                          title.split('\n').join(' '),
                          style: TextStyles.title1Emphasized,
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    SizedBox(height: 4.r),
                    ProductsTilesBuilder(
                      productTileBuilder: (
                        String productName,
                        String productSubtitle,
                        String productPrice,
                        bool isActive,
                        VoidCallback onTap,
                      ) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 4.r),
                          child: Material(
                            type: MaterialType.transparency,
                            borderRadius: BorderRadius.circular(18).r,
                            child: InkWell(
                              onTap: onTap,
                              borderRadius: BorderRadius.circular(18).r,
                              child: Ink(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isActive
                                          ? ColorStyles.primaryWithOpacity
                                          : null,
                                  borderRadius: BorderRadius.circular(18).r,
                                  border: Border.all(
                                    width: isActive ? 2 : 0.5,
                                    color: ColorStyles.primary,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            productName,
                                            style: TextStyles
                                                .subheadlineEmphasized
                                                .copyWith(
                                                  color: ColorStyles.primary,
                                                ),
                                          ),
                                          Text(
                                            productSubtitle,
                                            style: TextStyles.footnoteRegular
                                                .copyWith(
                                                  color: ColorStyles.primary
                                                      .withAlpha(
                                                        (255 * 0.6).toInt(),
                                                      ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 38,
                                      width: 0.5,
                                      color: ColorStyles.primary.withAlpha(
                                        (255 * 0.6).toInt(),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        productPrice,
                                        textAlign: TextAlign.end,
                                        style: TextStyles.subheadlineEmphasized
                                            .copyWith(
                                              color: ColorStyles.primary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8.r),
                    PurchaseButtonBuilder(
                      buttonBuilder: (String buttonText, AsyncCallback onTap) {
                        return WAFilledButton(
                          onPressed: onTap,
                          child: Text(buttonText),
                        );
                      },
                    ),
                    MainPaywallTermsAndPolicySection(),
                    HomeIndicatorSpace(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainPaywallTermsAndPolicySection extends StatelessWidget {
  const MainPaywallTermsAndPolicySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              openTermsOfUse(context);
            },
            child: Ink(
              height: 42.spMin,
              padding: EdgeInsets.symmetric(horizontal: 8.r),
              child: Center(
                child: Text('Terms of Use', style: TextStyles.footnoteRegular),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              openPrivacyPolicy(context);
            },
            child: Ink(
              height: 42.spMin,
              padding: EdgeInsets.symmetric(horizontal: 8.r),
              child: Center(
                child: Text(
                  'Privacy Policy',
                  style: TextStyles.footnoteRegular,
                ),
              ),
            ),
          ),
          RestorePurchaseButtonBuilder(
            buttonBuilder: (buttonText, onPressed) {
              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onPressed.call();
                },
                child: Ink(
                  height: 42.spMin,
                  padding: EdgeInsets.symmetric(horizontal: 8.r),
                  child: Center(
                    child: Text(buttonText, style: TextStyles.footnoteRegular),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
