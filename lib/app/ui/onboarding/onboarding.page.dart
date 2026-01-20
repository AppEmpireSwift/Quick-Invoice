import 'package:apphud_helper/apphud_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/core.dart';
import '../../../core/services/ui.helper.dart';
import '../../../core/ui/home_indicator_space.dart';
import '../../../gen/assets.gen.dart';
import '../../../style/style.dart';
import '../../app.dart';
import '../common/filled_button.dart';
import 'widgets/terms_policy_section.dart';

const _pageViewAnimationDuration = Duration(milliseconds: 250);

const _pageViewAnimationCurve = Curves.easeInOut;

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
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
    switch (uiHelper.deviceType) {
      case AppleDeviceType.iphoneSe:
        pages = [
          Assets.images.onboarding.onb1Se.path,
          Assets.images.onboarding.onb2Se.path,
          Assets.images.onboarding.onb3Se.path,
          Assets.images.onboarding.onb4Se.path,
        ];
      case AppleDeviceType.iphoneBase:
        pages = [
          Assets.images.onboarding.onb1.path,
          Assets.images.onboarding.onb2.path,
          Assets.images.onboarding.onb3.path,
          Assets.images.onboarding.onb4.path,
        ];
      case AppleDeviceType.ipad:
        if (uiHelper.isLandscape) {
          pages = [
            Assets.images.onboarding.onb1Album.path,
            Assets.images.onboarding.onb2Album.path,
            Assets.images.onboarding.onb3Album.path,
            Assets.images.onboarding.onb4Album.path,
          ];
        } else {
          pages = [
            Assets.images.onboarding.onb1Ipad.path,
            Assets.images.onboarding.onb2Ipad.path,
            Assets.images.onboarding.onb3Ipad.path,
            Assets.images.onboarding.onb4Ipad.path,
          ];
        }
    }

    /// Strings from your figma design
    final firstTitles = ['User Choice', 'We value', 'Use'];
    final secondTitles = [
      'Math Brain Booster',
      'Your Feedback',
      Core.config.appName,
      // 'Arithmetic Adventure',
    ];
    final descriptions = [
      'Exercise your brain, learn some quick\ncomputational know-how for fast computations',
      'Share your opinion about\n${Core.config.appName}',
      'Practice with lots of fun challenges\nand track your progress',
    ];

    final cloudText = [
      'Subscribe to unlimited exercise',
      'Unlock all practice',
      'Access to custom exercise editor',
    ];

    ///

    final lastPageNumber = pages.length - 1;
    return Scaffold(
      backgroundColor: ColorStyles.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              //comment this to use scroll for fast check ui
              // physics: NeverScrollableScrollPhysics(),
              children:
                  pages
                      .map(
                        (p) => Image.asset(
                          p,
                          fit: BoxFit.cover,
                          alignment: Alignment(0, -0.4),
                        ),
                      )
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
                    builder: (__, _) {
                      var pageNumber = _pageController.page?.round() ?? 0;

                      Widget page;

                      Widget titleSection;

                      ///build title
                      ///last page - onboarding paywall
                      if (pageNumber == lastPageNumber) {
                        titleSection = PaywallTitle(
                          titleBuilder: (title) {
                            //because at design we have two colors for title
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
                                        color: ColorStyles.primary,
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
                                style: TextStyle(color: ColorStyles.primary),
                              ),
                            ],
                          ),
                          style: TextStyles.onboarding,
                          textAlign: TextAlign.center,
                        );
                      }

                      Widget descriptionSection;

                      ///build description
                      ///last page - onboarding paywall
                      if (pageNumber == lastPageNumber) {
                        descriptionSection = OnBoardingPaywallActiveProductInfo(
                          infoBuilder: (
                            String subInfo,
                            String? limitedButton,
                            VoidCallback? onLimitedTap,
                          ) {
                            return Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: subInfo),
                                  if (limitedButton != null)
                                    TextSpan(text: '\n'),
                                  if (limitedButton != null)
                                    TextSpan(
                                      text: limitedButton,
                                      recognizer:
                                          TapGestureRecognizer()
                                            ..onTap = onLimitedTap,
                                    ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyles.subheadlineRegular.copyWith(
                                color: ColorStyles.labelsTertiary,
                              ),
                            );
                          },
                        );
                      } else {
                        descriptionSection = Text(
                          descriptions[pageNumber],
                          textAlign: TextAlign.center,
                          style: TextStyles.subheadlineRegular.copyWith(
                            color: ColorStyles.labelsTertiary,
                          ),
                        );
                      }

                      Widget button;

                      ///build button
                      ///last page - onboarding paywall
                      if (pageNumber == lastPageNumber) {
                        button = PurchaseButtonBuilder(
                          buttonBuilder: (buttonText, onPressed) {
                            return WAFilledButton(
                              onPressed: onPressed,
                              child: Center(child: Text(buttonText)),
                            );
                          },
                        );
                      } else {
                        button = WAFilledButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: _pageViewAnimationDuration,
                              curve: _pageViewAnimationCurve,
                            );
                          },
                          child: Center(child: Text('Continue')),
                        );
                      }

                      Widget cloud;

                      if (pageNumber == lastPageNumber) {
                        cloud = OnBoardingPaywallTrialSwitchBuilder(
                          switchBuilder: (
                            bool hide,
                            bool? value,
                            String? text,
                            onChange,
                          ) {
                            return Container(
                              height: 48.spMin,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100).r,
                                color: hide ? null : ColorStyles.bgSecondary,
                              ),

                              child:
                                  hide
                                      ? Container()
                                      : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(12.0.spMin),
                                            child: Text(
                                              text ?? '',
                                              style: TextStyles
                                                  .subheadlineRegular
                                                  .copyWith(
                                                    color: ColorStyles.black,
                                                  ),
                                            ),
                                          ),

                                          Padding(
                                            padding: EdgeInsets.only(
                                              right: 10.spMin,
                                            ),
                                            child: Switch.adaptive(
                                              value: value ?? false,
                                              onChanged:
                                                  (_) => onChange?.call(),
                                            ),
                                          ),
                                        ],
                                      ),
                            );
                          },
                        );
                      } else {
                        if (cloudText.length <= pageNumber ||
                            cloudText[pageNumber].isEmpty) {
                          cloud = Container(height: 48.spMin);
                        } else {
                          cloud = Container(
                            height: 48.spMin,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100).r,
                              color: ColorStyles.bgSecondary,
                            ),

                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(12.0.spMin),
                                  child: Text(
                                    cloudText[pageNumber],
                                    style: TextStyles.subheadlineRegular
                                        .copyWith(color: ColorStyles.black),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }

                      ///build page
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
                          SizedBox(height: 8.r),
                          titleSection,

                          SizedBox(height: 12.r),
                          descriptionSection,
                          SizedBox(height: 8.r),
                          cloud,
                          SizedBox(height: 6.r),
                          button,
                        ],
                      );

                      ///last page - onboarding paywall
                      ///wrap it with special wrapper
                      if (pageNumber == lastPageNumber) {
                        page = PaywallWrapper(
                          onSkipPaywallCallback: () {
                            OnBoardingHelper.markOnBoardingAsWatched();

                            //todo your router. for stage 2
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushReplacement(Home.route());
                          },
                          onSuccessPurchaseCallback: () {
                            OnBoardingHelper.markOnBoardingAsWatched();

                            //todo your router. for stage 2
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushReplacement(Home.route());
                          },
                          paywallType: PaywallType.onboarding,
                          paywallPage: page,
                        );
                      }

                      return page;
                    },
                  ),
                  TermsAndPolicySection(),
                  HomeIndicatorSpace(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
