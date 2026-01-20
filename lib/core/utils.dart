import 'package:flutter/material.dart';

import 'package:in_app_review/in_app_review.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher_string.dart';
import 'package:share_plus/share_plus.dart';

import 'ui/privacy_policy.page.dart';
import 'ui/terms_of_use.page.dart';
import 'core.dart';

Future<void> openPrivacyPolicy(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push(PrivacyPolicyPage.route());

Future<void> openTermsOfUse(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push(TermsOfUsePage.route());

Future<void> openRateApp() async {
  return InAppReview.instance.openStoreListing(appStoreId: Core.config.appId);
}

Future<void> shareApp(Rect? sharePositionOrigin) {
  return SharePlus.instance.share(
    ShareParams(
      uri: Uri.parse(Core.config.appStoreAppLink),
      sharePositionOrigin: sharePositionOrigin,
    ),
  );
}

Future<void> openSupport() async {
  if (await canLaunchUrlString(Core.config.supportForm)) {
    await launchUrlString(Core.config.supportForm);
  }
}

Future<void> contactUs() async {
  var url = Uri.encodeFull(
    'mailto:${Core.config.supportEmail}?subject=${Core.config.appName}&body=Hello!',
  );
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  }
}

Future<void> showAppVersion(BuildContext context) async {
  final packageInfo = await PackageInfo.fromPlatform();

  return showAdaptiveDialog(
    // ignore: use_build_context_synchronously
    context: context,
    builder:
        (_) => AlertDialog.adaptive(
          content: Text('App version: ${packageInfo.version}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.maybePop(context),
              child: Text('OK'),
            ),
          ],
        ),
  );
}

Future<void> checkAppUpdate(BuildContext context) async {
  var nvp = NewVersionPlus(iOSId: Core.config.appId);
  var vStat = await nvp.getVersionStatus();

  if (vStat != null && vStat.canUpdate) {
    return NewVersionPlus(
      iOSId: Core.config.appId,
      // ignore: use_build_context_synchronously
    ).showUpdateDialog(context: context, versionStatus: vStat);
  } else {
    return showAdaptiveDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder:
          (_) => AlertDialog.adaptive(
            content: Text('You’re using the latest version.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.maybePop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }
}
