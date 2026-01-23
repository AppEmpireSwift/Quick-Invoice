import 'package:apphud_helper/apphud_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../main_paywall.page.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../style/style.dart';

class AutoHiddablePremiumBanner extends StatelessWidget {
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const AutoHiddablePremiumBanner({
    super.key,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ApphudHelper.service.hasPremiumStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != false) return Container();
        return PremiumBanner(
          margin: margin,
          onTap: () {
            if (onTap != null) return onTap?.call();
            MainPaywallPage.show(context);
          },
        );
      },
    );
  }
}

class PremiumBanner extends StatelessWidget {
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  const PremiumBanner({super.key, this.onTap, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin?.r,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18).r,
        child: Stack(
          children: [
            Ink(
              padding: EdgeInsets.all(16).r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18).r,
                color: ColorStyles.primary,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Upgrade '),
                            TextSpan(
                              text: 'to Premium!',
                              style: TextStyle(color: ColorStyles.yellowDark),
                            ),
                          ],
                        ),
                        style: TextStyles.title3Emphasized.copyWith(
                          color: ColorStyles.white,
                        ),
                      ),
                      SizedBox(height: 4.r),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Get unlimited access'),
                            TextSpan(text: '\n'),
                            TextSpan(text: 'to all application features'),
                          ],
                        ),
                        style: TextStyles.footnoteRegular.copyWith(
                          color: ColorStyles.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: -10,
              bottom: -10,
              right: 0,
              child: Image.asset(
                Assets.images.premium.premiumBannerImage.path,
                width: 200.spMin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
