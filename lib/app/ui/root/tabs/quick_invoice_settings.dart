import 'package:apphud_helper/apphud_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/core.dart';
import '../../../../data/database.dart';
import '../../../../style/style.dart';
import '../../premium/widgets/premium_banner.dart';
import '../../premium/quick_invoice_main_paywall.page.dart';
import '../../../services/export_service.dart';

class QuickInvoiceSettingsTab extends StatefulWidget {
  const QuickInvoiceSettingsTab({super.key});

  @override
  State<QuickInvoiceSettingsTab> createState() => _QuickInvoiceSettingsTabState();
}

class _QuickInvoiceSettingsTabState extends State<QuickInvoiceSettingsTab> {
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      child: Column(
        children: [
          Container(
            width: double.infinity,
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
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  AutoHiddablePremiumBanner(margin: EdgeInsets.only(bottom: 16)),
                  _buildSection([
                    _buildItem(context, 'Company Info', () => _openCompanyInfo(context)),
                  ]),
                  SizedBox(height: 16.r),
                  _buildSection([
                    _buildItem(context, 'Export CSV', () => _exportCsv()),
                    _buildItem(context, 'Export Excel', () => _exportExcel()),
                  ]),
                  SizedBox(height: 16.r),
                  _buildSection([
                    _buildCurrentPlanItem(context),
                    _buildItem(context, 'Support', () => _openSupport()),
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
                    '${QICore.config.appName} v$_appVersion',
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

  Widget _buildCurrentPlanItem(BuildContext context) {
    return StreamBuilder<bool?>(
      stream: ApphudHelper.service.hasPremiumStream,
      builder: (context, snapshot) {
        final isPremium = snapshot.data ?? false;
        final planText = isPremium ? 'Premium' : 'Free';

        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.lightImpact();
            _openCurrentPlan(context);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Current Plan',
                    style: TextStyles.bodyRegular.copyWith(color: ColorStyles.primaryTxt),
                  ),
                ),
                Text(
                  planText,
                  style: TextStyles.bodyRegular.copyWith(
                    color: isPremium ? ColorStyles.primary : ColorStyles.secondary,
                  ),
                ),
                SizedBox(width: 8.r),
                Icon(CupertinoIcons.chevron_right, color: ColorStyles.secondary, size: 18.r),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openAppStore() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.openStoreListing(appStoreId: QICore.config.appId);
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    final sharePosition = Rect.fromLTWH(
      0,
      0,
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height / 2,
    );
    await ShareHelper.shareUri(
      uri: Uri.parse(QICore.config.appStoreAppLink),
      sharePosition: sharePosition,
    );
  }

  Future<void> _exportCsv() async {
    final invoices = await AppDatabase.instance.getAllInvoices();
    await ExportService.shareCsv(invoices);
  }

  Future<void> _exportExcel() async {
    final invoices = await AppDatabase.instance.getAllInvoices();
    await ExportService.shareExcel(invoices);
  }

  void _openPrivacyPolicy(BuildContext context) {
    showCupertinoSheet(
      context: context,
      builder: (_) => _PolicyPage(title: 'Privacy Policy', content: _privacyPolicyText),
    );
  }

  void _openTermsOfUse(BuildContext context) {
    showCupertinoSheet(
      context: context,
      builder: (_) => _PolicyPage(title: 'Terms of Use', content: _termsOfUseText),
    );
  }

  void _openCompanyInfo(BuildContext context) {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => const QuickInvoiceCompanyInfoPage()));
  }

  void _openCurrentPlan(BuildContext context) {
    QuickInvoiceMainPaywallPage.show(context);
  }

  Future<void> _openSupport() async {
    final uri = Uri(scheme: 'mailto', path: QICore.config.supportEmail);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static String get _privacyPolicyText => '''
This privacy policy applies to the ${QICore.config.appName} app (hereby referred to as "Application") for mobile devices that was created by (hereby referred to as "Service Provider") as a Free service. This service is intended for use "AS IS".


Information Collection and Use
The Application collects information when you download and use it. This information may include information such as

Your device's Internet Protocol address (e.g. IP address)
The pages of the Application that you visit, the time and date of your visit, the time spent on those pages
The time spent on the Application
The operating system you use on your mobile device

The Application does not gather precise information about the location of your mobile device.


The Service Provider may use the information you provided to contact you from time to time to provide you with important information, required notices and marketing promotions.


For a better experience, while using the Application, the Service Provider may require you to provide us with certain personally identifiable information. The information that the Service Provider request will be retained by them and used as described in this privacy policy.


Third Party Access
Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Service Provider may share your information with third parties in the ways that are described in this privacy statement.


The Service Provider may disclose User Provided and Automatically Collected Information:

as required by law, such as to comply with a subpoena, or similar legal process;
when they believe in good faith that disclosure is necessary to protect their rights, protect your safety or the safety of others, investigate fraud, or respond to a government request;
with their trusted services providers who work on their behalf, do not have an independent use of the information we disclose to them, and have agreed to adhere to the rules set forth in this privacy statement.

Opt-Out Rights
You can stop all collection of information by the Application easily by uninstalling it. You may use the standard uninstall processes as may be available as part of your mobile device or via the mobile application marketplace or network.


Data Retention Policy
The Service Provider will retain User Provided data for as long as you use the Application and for a reasonable time thereafter. If you'd like them to delete User Provided Data that you have provided via the Application, please contact them at ${QICore.config.supportEmail} and they will respond in a reasonable time.


Children
The Service Provider does not use the Application to knowingly solicit data from or market to children under the age of 13.


The Service Provider does not knowingly collect personally identifiable information from children. The Service Provider encourages all children to never submit any personally identifiable information through the Application and/or Services. The Service Provider encourage parents and legal guardians to monitor their children's Internet usage and to help enforce this Policy by instructing their children never to provide personally identifiable information through the Application and/or Services without their permission. If you have reason to believe that a child has provided personally identifiable information to the Service Provider through the Application and/or Services, please contact the Service Provider (${QICore.config.supportEmail}) so that they will be able to take the necessary actions. You must also be at least 16 years of age to consent to the processing of your personally identifiable information in your country (in some countries we may allow your parent or guardian to do so on your behalf).


Security
The Service Provider is concerned about safeguarding the confidentiality of your information. The Service Provider provides physical, electronic, and procedural safeguards to protect information the Service Provider processes and maintains.


Changes
This Privacy Policy may be updated from time to time for any reason. The Service Provider will notify you of any changes to the Privacy Policy by updating this page with the new Privacy Policy. You are advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes.


This privacy policy is effective as of 2026-01-23


Your Consent
By using the Application, you are consenting to the processing of your information as set forth in this Privacy Policy now and as amended by us.


Contact Us
If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider via email at ${QICore.config.supportEmail}.
''';

  static String get _termsOfUseText => '''
These terms and conditions apply to the ${QICore.config.appName} app (hereby referred to as "Application") for mobile devices that was created by (hereby referred to as "Service Provider") as a Free service.

Upon downloading or utilizing the Application, you are automatically agreeing to the following terms. It is strongly advised that you thoroughly read and understand these terms prior to using the Application.

Unauthorized copying, modification of the Application, any part of the Application, or our trademarks is strictly prohibited. Any attempts to extract the source code of the Application, translate the Application into other languages, or create derivative versions are not permitted. All trademarks, copyrights, database rights, and other intellectual property rights related to the Application remain the property of the Service Provider.

The Service Provider is dedicated to ensuring that the Application is as beneficial and efficient as possible. As such, they reserve the right to modify the Application or charge for their services at any time and for any reason. The Service Provider assures you that any charges for the Application or its services will be clearly communicated to you.

The Application stores and processes personal data that you have provided to the Service Provider in order to provide the Service. It is your responsibility to maintain the security of your phone and access to the Application. The Service Provider strongly advise against jailbreaking or rooting your phone, which involves removing software restrictions and limitations imposed by the official operating system of your device. Such actions could expose your phone to malware, viruses, malicious programs, compromise your phone's security features, and may result in the Application not functioning correctly or at all.

Please be aware that the Service Provider does not assume responsibility for certain aspects. Some functions of the Application require an active internet connection, which can be Wi-Fi or provided by your mobile network provider. The Service Provider cannot be held responsible if the Application does not function at full capacity due to lack of access to Wi-Fi or if you have exhausted your data allowance.

If you are using the application outside of a Wi-Fi area, please be aware that your mobile network provider's agreement terms still apply. Consequently, you may incur charges from your mobile provider for data usage during the connection to the application, or other third-party charges. By using the application, you accept responsibility for any such charges, including roaming data charges if you use the application outside of your home territory (i.e., region or country) without disabling data roaming. If you are not the bill payer for the device on which you are using the application, they assume that you have obtained permission from the bill payer.

Similarly, the Service Provider cannot always assume responsibility for your usage of the application. For instance, it is your responsibility to ensure that your device remains charged. If your device runs out of battery and you are unable to access the Service, the Service Provider cannot be held responsible.

In terms of the Service Provider's responsibility for your use of the application, it is important to note that while they strive to ensure that it is updated and accurate at all times, they do rely on third parties to provide information to them so that they can make it available to you. The Service Provider accepts no liability for any loss, direct or indirect, that you experience as a result of relying entirely on this functionality of the application.

The Service Provider may wish to update the application at some point. The application is currently available as per the requirements for the operating system (and for any additional systems they decide to extend the availability of the application to) may change, and you will need to download the updates if you want to continue using the application. The Service Provider does not guarantee that it will always update the application so that it is relevant to you and/or compatible with the particular operating system version installed on your device. However, you agree to always accept updates to the application when offered to you. The Service Provider may also wish to cease providing the application and may terminate its use at any time without providing termination notice to you. Unless they inform you otherwise, upon any termination, (a) the rights and licenses granted to you in these terms will end; (b) you must cease using the application, and (if necessary) delete it from your device.

**Changes to These Terms and Conditions**

The Service Provider may periodically update their Terms and Conditions. Therefore, you are advised to review this page regularly for any changes. The Service Provider will notify you of any changes by posting the new Terms and Conditions on this page.

These terms and conditions are effective as of 2026-01-23

**Contact Us**

If you have any questions or suggestions about the Terms and Conditions, please do not hesitate to contact the Service Provider at ${QICore.config.supportEmail}.
''';
}

class QuickInvoiceCompanyInfoPage extends StatefulWidget {
  const QuickInvoiceCompanyInfoPage({super.key});

  @override
  State<QuickInvoiceCompanyInfoPage> createState() => _QuickInvoiceCompanyInfoPageState();
}

class _QuickInvoiceCompanyInfoPageState extends State<QuickInvoiceCompanyInfoPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
  }

  Future<void> _loadCompanyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('company_name') ?? '';
      _emailController.text = prefs.getString('company_email') ?? '';
      _phoneController.text = prefs.getString('company_phone') ?? '';
      _addressController.text = prefs.getString('company_address') ?? '';
      _taxIdController.text = prefs.getString('company_tax_id') ?? '';
      _websiteController.text = prefs.getString('company_website') ?? '';
    });
  }

  Future<void> _saveCompanyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('company_name', _nameController.text);
    await prefs.setString('company_email', _emailController.text);
    await prefs.setString('company_phone', _phoneController.text);
    await prefs.setString('company_address', _addressController.text);
    await prefs.setString('company_tax_id', _taxIdController.text);
    await prefs.setString('company_website', _websiteController.text);

    if (mounted) {
      HapticFeedback.lightImpact();
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Company Info'),
        backgroundColor: ColorStyles.white,
        automaticBackgroundVisibility: false,
        transitionBetweenRoutes: false,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Company Name',
                placeholder: 'Enter company name',
              ),
              SizedBox(height: 16.r),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                placeholder: 'company@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.r),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone',
                placeholder: '+1 234 567 890',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.r),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                placeholder: 'Company address',
                maxLines: 3,
              ),
              SizedBox(height: 16.r),
              _buildTextField(
                controller: _taxIdController,
                label: 'Tax ID',
                placeholder: 'Tax identification number',
              ),
              SizedBox(height: 16.r),
              _buildTextField(
                controller: _websiteController,
                label: 'Website',
                placeholder: 'www.company.com',
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 24.r),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveCompanyInfo,
                child: Container(
                  width: double.infinity,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: ColorStyles.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Save',
                      style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100.r),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.secondary)),
        SizedBox(height: 8.r),
        Container(
          decoration: BoxDecoration(
            color: ColorStyles.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: CupertinoTextField(
            controller: controller,
            style: TextStyles.bodyRegular.copyWith(color: ColorStyles.primaryTxt),
            placeholder: placeholder,
            placeholderStyle: TextStyles.bodyRegular.copyWith(
              color: ColorStyles.secondary.withValues(alpha: 0.5),
            ),
            padding: EdgeInsets.all(16.r),
            decoration: null,
            keyboardType: keyboardType,
            maxLines: maxLines,
          ),
        ),
      ],
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
      backgroundColor: ColorStyles.white,
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        backgroundColor: ColorStyles.white,
        transitionBetweenRoutes: false,
        automaticBackgroundVisibility: false,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(CupertinoIcons.xmark, size: 20.r, color: ColorStyles.secondary),
        ),
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
