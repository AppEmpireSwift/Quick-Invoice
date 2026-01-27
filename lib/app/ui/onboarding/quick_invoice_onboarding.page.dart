import 'package:apphud_helper/apphud_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/core.dart';
import '../../../core/services/quick_invoice_ui_helper.dart';
import '../../../core/ui/home_indicator_space.dart';
import '../../../gen/assets.gen.dart';
import '../../../style/style.dart';
import '../../app.dart';
import '../common/filled_button.dart';
import '../company/quick_invoice_company_info.dart';
import 'widgets/terms_policy_section.dart';

class QuickInvoiceOnBoardingPage extends StatefulWidget {
  const QuickInvoiceOnBoardingPage({super.key});

  @override
  State<QuickInvoiceOnBoardingPage> createState() => _QuickInvoiceOnBoardingPageState();
}

class _QuickInvoiceOnBoardingPageState extends State<QuickInvoiceOnBoardingPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> pages;
    switch (quickInvoiceUIHelper.deviceType) {
      case DeviceType.iphoneSe:
        pages = [
          Assets.images.onboarding.onb1Se.path,
          Assets.images.onboarding.onb2Se.path,
          Assets.images.onboarding.onb3Se.path,
          Assets.images.onboarding.onb4Se.path,
          Assets.images.onboarding.onb5Se.path,
        ];
      case DeviceType.iphoneBase:
        pages = [
          Assets.images.onboarding.onb1.path,
          Assets.images.onboarding.onb2.path,
          Assets.images.onboarding.onb3.path,
          Assets.images.onboarding.onb4.path,
          Assets.images.onboarding.onb5.path,
        ];
      case DeviceType.ipad:
        if (quickInvoiceUIHelper.isLandscape) {
          pages = [
            Assets.images.onboarding.onb1Album.path,
            Assets.images.onboarding.onb2Album.path,
            Assets.images.onboarding.onb3Album.path,
            Assets.images.onboarding.onb4Album.path,
            Assets.images.onboarding.onb5Album.path,
          ];
        } else {
          pages = [
            Assets.images.onboarding.onb1Ipad.path,
            Assets.images.onboarding.onb2Ipad.path,
            Assets.images.onboarding.onb3Ipad.path,
            Assets.images.onboarding.onb4Ipad.path,
            Assets.images.onboarding.onb5Ipad.path,
          ];
        }
    }

    final firstTitles = ['Invoice', 'Send', 'Use', 'Select', 'We Value'];
    final secondTitles = ['Making', 'to Client', 'Template', 'Your Feedback'];
    final descriptions = [
      "Create invoices from scratch or use\nready-made templates",
      "Share invoices with your personal customer base,\nand send them directly from the app",
      "Choose a convenient template for work and\ntransform your invoice",
      "Any feedback is impoxrtant to us so that\nwe could improve our app!",
    ];

    final cloudText = [
      'Unlimited invoices',
      'Build a customer base',
      'Use templates',
      'Check why users love it',
    ];

    final lastPageNumber = pages.length - 1;
    return Scaffold(
      backgroundColor: ColorStyles.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: pages
                  .map((p) => Image.asset(p, fit: BoxFit.cover, alignment: Alignment(0, -0.4)))
                  .toList(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14).r,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListenableBuilder(
                    listenable: _pageController,
                    builder: (_, _) {
                      var pageNumber = _pageController.page?.round() ?? 0;

                      Widget page;

                      Widget titleSection;

                      if (pageNumber == lastPageNumber) {
                        titleSection = PaywallTitle(
                          titleBuilder: (title) {
                            final titles = title.split('\n');
                            return Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: titles.first),
                                  if (titles.length > 1) TextSpan(text: '\n'),
                                  if (titles.length > 1)
                                    TextSpan(
                                      text: titles.last,
                                      style: TextStyle(
                                        fontSize: 22.spMin,
                                        letterSpacing: -0.4,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                ],
                              ),
                              style: TextStyles.onboarding,
                              textAlign: TextAlign.center,
                            );
                          },
                        );
                      } else {
                        titleSection = Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: firstTitles[pageNumber]),
                              TextSpan(text: '\n'),
                              TextSpan(
                                text: secondTitles[pageNumber],
                                style: TextStyle(
                                  fontSize: 24.spMin,
                                  letterSpacing: -0.4,
                                  color: CupertinoColors.black,
                                ),
                              ),
                            ],
                          ),
                          style: TextStyles.onboarding,
                          textAlign: TextAlign.center,
                        );
                      }

                      Widget descriptionSection;

                      if (pageNumber == lastPageNumber) {
                        descriptionSection = OnBoardingPaywallActiveProductInfo(
                          infoBuilder:
                              (String subInfo, String? limitedButton, VoidCallback? onLimitedTap) {
                                return Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: subInfo),
                                      if (limitedButton != null) TextSpan(text: '\n'),
                                      if (limitedButton != null)
                                        TextSpan(
                                          text: limitedButton,
                                          recognizer: TapGestureRecognizer()..onTap = onLimitedTap,
                                        ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp.clamp(0, 19),
                                    letterSpacing: -0.23,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(60, 60, 67, 0.6),
                                  ),
                                );
                              },
                        );
                      } else {
                        descriptionSection = Text(
                          descriptions[pageNumber],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp.clamp(0, 19),
                            letterSpacing: -0.23,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(60, 60, 67, 0.6),
                          ),
                        );
                      }

                      Widget button;
                      if (pageNumber == lastPageNumber) {
                        button = PurchaseButtonBuilder(
                          buttonBuilder: (buttonText, onPressed) {
                            return QIFilledButton(
                              onPressed: onPressed,
                              child: Center(
                                child: Text(
                                  buttonText,
                                  style: TextStyle(
                                    fontSize: 18.sp.clamp(0, 24),
                                    fontWeight: FontWeight.w600,
                                    color: ColorStyles.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        button = QIFilledButton(
                          onPressed: () {
                            _pageController.jumpToPage((_pageController.page?.round() ?? 0) + 1);
                          },
                          child: Center(
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18.sp.clamp(0, 24),
                                fontWeight: FontWeight.w600,
                                color: ColorStyles.white,
                              ),
                            ),
                          ),
                        );
                      }

                      Widget cloud;

                      if (pageNumber == lastPageNumber) {
                        cloud = OnBoardingPaywallTrialSwitchBuilder(
                          switchBuilder: (bool hide, bool? value, String? text, onChange) {
                            return Container(
                              height: 48.spMin,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100).r,
                                color: hide ? null : Color.fromRGBO(203, 221, 255, 0.33),
                              ),

                              child: hide
                                  ? Container()
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(12.0.spMin),
                                          child: Text(
                                            text ?? '',
                                            style: TextStyles.subheadlineRegular.copyWith(
                                              color: ColorStyles.black,
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: EdgeInsets.only(right: 10.spMin),
                                          child: Switch.adaptive(
                                            value: value ?? false,
                                            onChanged: (_) => onChange?.call(),
                                          ),
                                        ),
                                      ],
                                    ),
                            );
                          },
                        );
                      } else {
                        if (cloudText.length <= pageNumber || cloudText[pageNumber].isEmpty) {
                          cloud = Container(height: 48.spMin);
                        } else {
                          cloud = Container(
                            height: 48.spMin,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100).r,
                              color: Color.fromRGBO(203, 221, 255, 0.33),
                            ),

                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(12.0.spMin),
                                  child: Text(
                                    cloudText[pageNumber],
                                    style: TextStyles.subheadlineRegular.copyWith(
                                      color: ColorStyles.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                      page = Column(
                        children: [
                          SizedBox(
                            height: 26.r,
                            child: SmoothPageIndicator(
                              effect: ExpandingDotsEffect(
                                dotColor: ColorStyles.primaryWithOpacity,
                                activeDotColor: ColorStyles.primary,
                                dotHeight: 6.r,
                                dotWidth: 6.r,
                                expansionFactor: 4,
                                spacing: 4.r,
                              ),
                              controller: _pageController,
                              count: pages.length,
                            ),
                          ),
                          titleSection,
                          SizedBox(height: 6.h.clamp(0, 6)),
                          descriptionSection,
                          SizedBox(height: 8.h.clamp(0, 8)),
                          cloud,
                          SizedBox(height: 6.h.clamp(0, 6)),
                          button,
                        ],
                      );
                      if (pageNumber == lastPageNumber) {
                        page = PaywallWrapper(
                          onSkipPaywallCallback: () {
                            QIBoardingHelper.markOnBoardingAsWatched();
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushReplacement(QuickInvoiceCompanyInfoPage.route());
                          },
                          onSuccessPurchaseCallback: () {
                            QIBoardingHelper.markOnBoardingAsWatched();
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushReplacement(QuickInvoiceCompanyInfoPage.route());
                          },
                          paywallType: PaywallType.onboarding,
                          paywallPage: page,
                        );
                      }

                      return page;
                    },
                  ),
                  TermsAndPolicySection(),
                  QIHomeIndicatorSpace(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
