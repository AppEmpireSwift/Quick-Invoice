import 'package:apphud_helper/apphud_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../quick_invoice_main_paywall.page.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../style/quick_invoice_style.dart';

class QuickInvoiceAutoHiddableBanner extends StatelessWidget {
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const QuickInvoiceAutoHiddableBanner({
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
        return QuickInvoicePremiumBanner(
          margin: margin,
          onTap: () {
            if (onTap != null) return onTap?.call();
            Navigator.of(
              context,
              rootNavigator: true,
            ).push(CupertinoPageRoute(builder: (_) => const QuickInvoiceMainPaywallPage()));
          },
        );
      },
    );
  }
}

class QuickInvoicePremiumBanner extends StatelessWidget {
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  const QuickInvoicePremiumBanner({super.key, this.onTap, this.margin});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        height: 118.h,
        margin: margin?.r,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(16).r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18).r,
                color: QuickInvoiceColorStyles.primary,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'GO PREMIUM',
                        style: TextStyle(
                          fontSize: 32.sp.clamp(0, 38),
                          color: QuickInvoiceColorStyles.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.r),
                      Text(
                        'Unlock Full Access!',
                        style: TextStyle(
                          fontSize: 17.sp.clamp(0, 23),
                          fontWeight: FontWeight.w400,
                          color: QuickInvoiceColorStyles.white,
                          letterSpacing: -0.4,
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
                width: 118.spMin,
                height: 118.spMin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
