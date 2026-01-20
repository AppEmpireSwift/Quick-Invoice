import 'package:apphud_helper/apphud_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_wa_skeleton/app/ui/premium/main_paywall.page.dart';
import 'package:flutter_wa_skeleton/app/ui/premium/widgets/premium_banner.dart';

import '../../../core/core.dart';
import '../common/back_button.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  static Route route() => MaterialPageRoute(builder: (_) => SettingsPage());

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leadingWidth: 70, leading: WABackButton(), title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16).r,
        children: [
          SettingsSection(
            children: [
              StreamBuilder<bool>(
                stream: ApphudHelper.service.hasPremiumStream,
                builder: (context, snapshot) {
                  return SettingsTile(
                    title: 'Current plan',
                    status: snapshot.data == true ? 'Premium' : 'Basic',
                    onTap: () {
                      //todo your router. for stage 2
                      Navigator.of(context, rootNavigator: true).push(MainPaywallPage.route());
                    },
                  );
                },
              ),

              SettingsTile(title: 'Current version', onTap: () => showAppVersion(context)),
              Builder(
                builder: (context) {
                  return SettingsTile(
                    title: 'Share ${Core.config.appName}',
                    onTap: () {
                      final box = context.findRenderObject() as RenderBox?;

                      shareApp(box!.localToGlobal(Offset.zero) & box.size);
                    },
                  );
                },
              ),
              SettingsTile(title: 'Rate App', onTap: openRateApp),
            ],
          ),
          SizedBox(height: 8.r),
          AutoHiddablePremiumBanner(),
          SizedBox(height: 8.r),

          SettingsSection(
            children: [
              SettingsTile(
                title: 'Support',
                onTap: () {
                  contactUs();
                },
              ),
            ],
          ),
          SizedBox(height: 16.r),
          SettingsSection(
            children: [
              SettingsTile(title: 'App update', onTap: () => checkAppUpdate(context)),

              SettingsTile(title: 'Privacy Policy', onTap: () => openPrivacyPolicy(context)),
              SettingsTile(title: 'Terms of Use', onTap: () => openTermsOfUse(context)),
            ],
          ),
        ],
      ),
    );
  }
}
