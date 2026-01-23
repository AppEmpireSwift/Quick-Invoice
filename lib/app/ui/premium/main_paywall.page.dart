import 'package:apphud_helper/apphud_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/core.dart';
import '../../../style/style.dart';
import '../common/filled_button.dart';

class MainPaywallPage extends StatelessWidget {
  const MainPaywallPage({super.key});

  static void show(BuildContext context) {
    showCupertinoSheet(
      context: context,
      builder: (_) => const MainPaywallPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaywallWrapper(
      onSkipPaywallCallback: () {
        Navigator.pop(context);
      },
      onSuccessPurchaseCallback: () {
        Navigator.pop(context, true);
      },
      paywallType: PaywallType.main,
      paywallPage: CupertinoPageScaffold(
        backgroundColor: ColorStyles.white,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: ColorStyles.white,
          border: null,
          leading: const SizedBox.shrink(),
          trailing: PaywallCloseButton(
            buttonBuilder:
                (onClose) => CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onClose,
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: ColorStyles.secondary,
                    size: 28.r,
                  ),
                ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80.r,
                        height: 80.r,
                        decoration: BoxDecoration(
                          color: ColorStyles.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.star_fill,
                          size: 40.r,
                          color: ColorStyles.primary,
                        ),
                      ),
                      SizedBox(height: 24.r),
                      PaywallTitle(
                        titleBuilder: (String title) {
                          return Text(
                            title.split('\n').join(' '),
                            style: TextStyles.title1Emphasized,
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                      SizedBox(height: 8.r),
                      PaywallActiveProductInfo(
                        infoBuilder: (
                          String activeProductInfo,
                          String? limitedText,
                          _,
                        ) {
                          return Text(
                            activeProductInfo,
                            textAlign: TextAlign.center,
                            style: TextStyles.footnoteRegular.copyWith(
                              color: ColorStyles.secondary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                ProductsTilesBuilder(
                  productTileBuilder: (
                    String productName,
                    String productSubtitle,
                    String productPrice,
                    bool isActive,
                    VoidCallback onTap,
                  ) {
                    return GestureDetector(
                      onTap: onTap,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4.r),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.r,
                          vertical: 12.r,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? ColorStyles.primaryWithOpacity
                                  : ColorStyles.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            width: isActive ? 2 : 0.5,
                            color:
                                isActive
                                    ? ColorStyles.primary
                                    : ColorStyles.separator,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName,
                                    style: TextStyles.bodyEmphasized.copyWith(
                                      color: ColorStyles.primaryTxt,
                                    ),
                                  ),
                                  if (productSubtitle.isNotEmpty)
                                    Text(
                                      productSubtitle,
                                      style: TextStyles.footnoteRegular
                                          .copyWith(
                                            color: ColorStyles.secondary,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              productPrice,
                              style: TextStyles.bodyEmphasized.copyWith(
                                color: ColorStyles.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.r),
                PurchaseButtonBuilder(
                  buttonBuilder: (String buttonText, AsyncCallback onTap) {
                    return WAFilledButton(
                      onPressed: onTap,
                      child: Text(buttonText),
                    );
                  },
                ),
                SizedBox(height: 8.r),
                _TermsSection(),
                SizedBox(height: 8.r),
              ],
            ),
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
              'Terms',
              style: TextStyles.caption1Regular.copyWith(
                color: ColorStyles.secondary,
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 8.r),
            sizeStyle: CupertinoButtonSize.small,
            onPressed: () {
              HapticFeedback.lightImpact();
              openPrivacyPolicy(context);
            },
            child: Text(
              'Privacy',
              style: TextStyles.caption1Regular.copyWith(
                color: ColorStyles.secondary,
              ),
            ),
          ),
          RestorePurchaseButtonBuilder(
            buttonBuilder: (buttonText, onPressed) {
              return CupertinoButton(
                sizeStyle: CupertinoButtonSize.small,
                padding: EdgeInsets.symmetric(horizontal: 8.r),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onPressed.call();
                },
                child: Text(
                  buttonText,
                  style: TextStyles.caption1Regular.copyWith(
                    color: ColorStyles.secondary,
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
