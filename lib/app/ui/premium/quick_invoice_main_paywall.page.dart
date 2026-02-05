import 'package:apphud_helper/apphud_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:quick_invoice/app/app.dart';

import '../../../core/core.dart';
import '../../../core/services/quick_invoice_ui_helper.dart';
import '../../../gen/assets.gen.dart';
import '../../../style/quick_invoice_style.dart';
import '../common/filled_button.dart';

class QuickInvoiceMainPaywallPage extends StatelessWidget {
  const QuickInvoiceMainPaywallPage({super.key});

  static void show(BuildContext context) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(CupertinoPageRoute(builder: (_) => const QuickInvoiceMainPaywallPage()));
  }

  @override
  Widget build(BuildContext context) {
    String bg;
    switch (quickInvoiceUIHelper.deviceType) {
      case DeviceType.iphoneSe:
        bg = Assets.images.premium.paywallSe.path;
      case DeviceType.iphoneBase:
        bg = Assets.images.premium.paywall.path;
      case DeviceType.ipad:
        if (quickInvoiceUIHelper.isLandscape) {
          bg = Assets.images.premium.paywallAlbum.path;
        } else {
          bg = Assets.images.premium.paywallIpad.path;
        }
    }
    return PaywallWrapper(
      onSkipPaywallCallback: () {
        Navigator.pop(context);
      },
      onSuccessPurchaseCallback: () {
        Navigator.pop(context, true);
      },
      paywallType: PaywallType.main,
      paywallPage: CupertinoPageScaffold(
        backgroundColor: QuickInvoiceColorStyles.white,
        child: SafeArea(
          top: false,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: Image.asset(bg, fit: BoxFit.cover)),
              Positioned(
                right: 10,
                child: SafeArea(
                  child: PaywallCloseButton(
                    buttonBuilder: (onClose) => CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: onClose,
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: QuickInvoiceColorStyles.secondary,
                        size: 28.r,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PaywallActiveProductInfo(
                        infoBuilder: (String activeProductInfo, String? limitedText, _) {
                          return Text(
                            activeProductInfo,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp.clamp(0, 19),
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.4,
                              color: Color.fromRGBO(60, 60, 67, 0.6),
                            ),
                          );
                        },
                      ),
                      PaywallTitle(
                        titleBuilder: (String title) {
                          return Text(
                            title.split('\n').join(' '),
                            style: TextStyle(
                              fontSize: 26.sp.clamp(0, 32),
                              color: CupertinoColors.black,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                      SizedBox(height: 4.r),
                      ProductsTilesBuilder(
                        productTileBuilder:
                            (
                              String productName,
                              String productSubtitle,
                              String productPrice,
                              bool isActive,
                              VoidCallback onTap,
                            ) {
                              return GestureDetector(
                                onTap: onTap,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 4.h),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.h,
                                    vertical: 8.h.clamp(0, 8),
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Color.fromRGBO(0, 136, 255, 1)
                                        : Color.fromRGBO(238, 244, 255, 1),
                                    borderRadius: BorderRadius.circular(18.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              productName,
                                              style: TextStyle(
                                                fontSize: 15.sp.clamp(0, 15),
                                                fontWeight: FontWeight.w700,
                                                color: isActive
                                                    ? QuickInvoiceColorStyles.white
                                                    : QuickInvoiceColorStyles.primaryTxt,
                                              ),
                                            ),
                                            Text(
                                              productSubtitle,
                                              style: TextStyle(
                                                fontSize: 13.sp.clamp(0, 13),
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: -0.04,
                                                color: isActive
                                                    ? QuickInvoiceColorStyles.white
                                                    : Color.fromRGBO(60, 60, 67, 0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          productPrice,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 15.sp.clamp(0, 15),
                                            fontWeight: FontWeight.w700,
                                            color: isActive
                                                ? QuickInvoiceColorStyles.white
                                                : QuickInvoiceColorStyles.primaryTxt,
                                            letterSpacing: -0.23,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                      ),
                      SizedBox(height: 8.r),
                      PurchaseButtonBuilder(
                        buttonBuilder: (String buttonText, AsyncCallback onTap) {
                          return QIFilledButton(
                            onPressed: onTap,
                            child: Text(
                              buttonText,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: QuickInvoiceColorStyles.white,
                              ).rz,
                            ),
                          );
                        },
                      ),
                      _TermsSection(),
                      SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 8.r : 16.r),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 8.r),
            sizeStyle: CupertinoButtonSize.small,
            onPressed: () {
              HapticFeedback.lightImpact();
              openTermsOfUse(context);
            },
            child: Text(
              'Terms of Use',
              style: TextStyle(
                fontSize: 13.sp.clamp(0, 19),
                fontWeight: FontWeight.w400,
                letterSpacing: -0.04,
                color: Color.fromRGBO(153, 153, 153, 1),
              ),
            ),
          ),
          RestorePurchaseButtonBuilder(
            buttonBuilder: (buttonText, onPressed) {
              return CupertinoButton(
                padding: EdgeInsets.symmetric(horizontal: 8.r),
                sizeStyle: CupertinoButtonSize.small,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onPressed.call();
                },
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 13.sp.clamp(0, 19),
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.04,
                    color: Color.fromRGBO(153, 153, 153, 1),
                  ),
                ),
              );
            },
          ),
          CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 8.r),
            sizeStyle: CupertinoButtonSize.small,
            onPressed: () {
              HapticFeedback.lightImpact();
              openPrivacyPolicy(context);
            },
            child: Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 13.sp.clamp(0, 19),
                fontWeight: FontWeight.w400,
                letterSpacing: -0.04,
                color: Color.fromRGBO(153, 153, 153, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
