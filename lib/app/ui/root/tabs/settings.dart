import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/core.dart';
import '../../../../style/style.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: ColorStyles.white,
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50.r),
                  Text('Settings', style: TextStyles.largeTitleEmphasized),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  _buildSection([
                    _buildItem(context, 'Profile', () {}),
                    _buildItem(context, 'Company Info', () {}),
                  ]),
                  SizedBox(height: 16.r),
                  _buildSection([
                    _buildItem(context, 'Share App', () => _shareApp(context)),
                    _buildItem(context, 'Rate Us', () => _openAppStore()),
                  ]),
                  SizedBox(height: 16.r),
                  _buildSection([
                    _buildItem(context, 'Privacy Policy', () => _openPrivacyPolicy(context)),
                    _buildItem(context, 'Terms of Use', () => _openTermsOfUse(context)),
                  ]),
                  SizedBox(height: 24.r),
                  Text(
                    'Quick Invoice v1.0.0',
                    style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.secondary),
                  ),
                  SizedBox(height: 100.r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: ColorStyles.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children:
            items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast) Divider(height: 1, indent: 16.r, color: ColorStyles.separator),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, VoidCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        debugPrint('Settings item tapped: $title');
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyles.bodyRegular.copyWith(color: ColorStyles.primaryTxt),
              ),
            ),
            Icon(CupertinoIcons.chevron_right, color: ColorStyles.secondary, size: 18.r),
          ],
        ),
      ),
    );
  }

  Future<void> _openAppStore() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.openStoreListing(appStoreId: Core.config.appId);
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    final sharePosition = Rect.fromLTWH(
      0,
      0,
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height / 2,
    );
    try {
      await SharePlus.instance.share(
        ShareParams(
          uri: Uri.parse(Core.config.appStoreAppLink),
          sharePositionOrigin: sharePosition,
        ),
      );
    } on PlatformException catch (e) {
      if (e.message?.contains('sharePositionOrigin') ?? false) {
        await SharePlus.instance.share(
          ShareParams(
            uri: Uri.parse(Core.config.appStoreAppLink),
            sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
          ),
        );
      }
    }
  }

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => _PolicyPage(title: 'Privacy Policy', content: _privacyPolicyText),
      ),
    );
  }

  void _openTermsOfUse(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => _PolicyPage(title: 'Terms of Use', content: _termsOfUseText),
      ),
    );
  }
}

class _PolicyPage extends StatelessWidget {
  final String title;
  final String content;

  const _PolicyPage({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        backgroundColor: ColorStyles.white,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Text(
            content,
            style: TextStyles.bodyRegular.copyWith(color: ColorStyles.primaryTxt),
          ),
        ),
      ),
    );
  }
}

String get _privacyPolicyText => '''
This privacy policy applies to the ${Core.config.appName} app (hereby referred to as "Application") for mobile devices that was created by The Developer (hereby referred to as "Service Provider") as a Freemium service. This service is intended for use "AS IS".

What information does the Application obtain and how is it used?
The Application does not obtain any information when you download and use it. Registration is not required to use the Application.

Does the Application collect precise real time location information of the device?
This Application does not collect precise information about the location of your mobile device.

Do third parties see and/or have access to information obtained by the Application?
Since the Application does not collect any information, no data is shared with third parties.

What are my opt-out rights?
You can stop all collection of information by the Application easily by uninstalling it. You may use the standard uninstall processes as may be available as part of your mobile device or via the mobile application marketplace or network.

Children
The Application is not used to knowingly solicit data from or market to children under the age of 13.

Security
The Service Provider is concerned about safeguarding the confidentiality of your information. However, since the Application does not collect any information, there is no risk of your data being accessed by unauthorized individuals.

Changes
This Privacy Policy may be updated from time to time for any reason. The Service Provider will notify you of any changes to their Privacy Policy by updating this page with the new Privacy Policy.

Your Consent
By using the Application, you are consenting to the processing of your information as set forth in this Privacy Policy now and as amended by the Service Provider.

Contact Us
If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider via email at ${Core.config.supportEmail}.
''';

String get _termsOfUseText => '''
These terms and conditions apply to the ${Core.config.appName} app (hereby referred to as "Application") for mobile devices that was created by The Developer (hereby referred to as "Service Provider") as a Freemium service.

Upon downloading or utilizing the Application, you are automatically agreeing to the following terms. It is strongly advised that you thoroughly read and understand these terms prior to using the Application.

The Service Provider is dedicated to ensuring that the Application is as beneficial and efficient as possible. As such, they reserve the right to modify the Application or charge for their services at any time and for any reason.

The Application stores and processes personal data that you have provided to the Service Provider in order to provide the Service. It is your responsibility to maintain the security of your phone and access to the Application.

Please be aware that the Service Provider does not assume responsibility for certain aspects. Some functions of the Application require an active internet connection, which can be Wi-Fi or provided by your mobile network provider.

Changes to These Terms and Conditions
The Service Provider may periodically update their Terms and Conditions. Therefore, you are advised to review this page regularly for any changes.

Contact Us
If you have any questions or suggestions about the Terms and Conditions, please do not hesitate to contact the Service Provider at ${Core.config.supportEmail}.
''';
