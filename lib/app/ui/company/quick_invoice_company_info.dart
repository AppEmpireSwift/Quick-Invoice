import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../style/quick_invoice_style.dart';
import '../../../core/core.dart';

class QuickInvoiceCompanyInfoPage extends StatefulWidget {
  const QuickInvoiceCompanyInfoPage({super.key});

  static Route route() => CupertinoPageRoute(builder: (_) => const QuickInvoiceCompanyInfoPage());

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
    _loadSavedCompanyInfo();
  }

  Future<void> _loadSavedCompanyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    _nameController.text = prefs.getString('company_name') ?? '';
    _emailController.text = prefs.getString('company_email') ?? '';
    _phoneController.text = prefs.getString('company_phone') ?? '';
    _addressController.text = prefs.getString('company_address') ?? '';
    _taxIdController.text = prefs.getString('company_tax_id') ?? '';
    _websiteController.text = prefs.getString('company_website') ?? '';
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

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('company_name', _nameController.text.trim());
    await prefs.setString('company_email', _emailController.text.trim());
    await prefs.setString('company_phone', _phoneController.text.trim());
    await prefs.setString('company_address', _addressController.text.trim());
    await prefs.setString('company_tax_id', _taxIdController.text.trim());
    await prefs.setString('company_website', _websiteController.text.trim());
    await prefs.setBool('company_info_filled', true);
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushReplacement(QIHome.route());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: QuickInvoiceColorStyles.bgSecondary,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.r),
              Text('Company Info', style: QuickInvoiceTextStyles.largeTitleEmphasized),
              SizedBox(height: 8.r),
              Text(
                'This information will appear on your invoices',
                style: QuickInvoiceTextStyles.footnoteRegular.copyWith(
                  color: QuickInvoiceColorStyles.secondary,
                ),
              ),
              SizedBox(height: 32.r),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: QuickInvoiceColorStyles.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    _buildField('Company Name', 'Your company name', _nameController),
                    SizedBox(height: 16.r),
                    _buildField(
                      'Email',
                      'company@email.com',
                      _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.r),
                    _buildField(
                      'Phone',
                      '+1 234 567 890',
                      _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16.r),
                    _buildField('Address', 'Company address', _addressController),
                    SizedBox(height: 16.r),
                    _buildField('Tax ID', 'Tax identification number', _taxIdController),
                    SizedBox(height: 16.r),
                    _buildField(
                      'Website',
                      'www.company.com',
                      _websiteController,
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.r),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _save();
                },
                child: Container(
                  width: double.infinity,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: QuickInvoiceColorStyles.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Continue',
                      style: QuickInvoiceTextStyles.bodyEmphasized.copyWith(
                        color: QuickInvoiceColorStyles.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String placeholder,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: QuickInvoiceTextStyles.footnoteRegular.copyWith(
            color: QuickInvoiceColorStyles.secondary,
          ),
        ),
        SizedBox(height: 8.r),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          padding: EdgeInsets.all(12.r),
          keyboardType: keyboardType,
          decoration: BoxDecoration(
            color: QuickInvoiceColorStyles.fillsTertiary,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ],
    );
  }
}
