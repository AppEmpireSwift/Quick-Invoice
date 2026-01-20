import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../style/style.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: ColorStyles.white.withValues(alpha: 0.9),
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50.r),
                  Text('Invoices', style: TextStyles.largeTitleEmphasized),
                  SizedBox(height: 16.r),
                  CupertinoSearchTextField(
                    placeholder: 'Search invoices...',
                    style: TextStyles.bodyRegular,
                    placeholderStyle: TextStyles.bodyRegular.copyWith(color: ColorStyles.labelsTertiary),
                    backgroundColor: ColorStyles.fillsTertiary,
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.doc_text, size: 64.r, color: ColorStyles.labelsTertiary),
                SizedBox(height: 16.r),
                Text('No invoices yet', style: TextStyles.title3Emphasized),
                SizedBox(height: 8.r),
                Text(
                  'Create your first invoice',
                  style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.labelsTertiary),
                ),
                SizedBox(height: 24.r),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (_) => const CreateInvoicePage()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50.r,
                    margin: EdgeInsets.symmetric(horizontal: 32.r),
                    decoration: BoxDecoration(
                      color: ColorStyles.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        'Create Invoice',
                        style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100.r),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreateInvoicePage extends StatelessWidget {
  const CreateInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      navigationBar: CupertinoNavigationBar(
        middle: Text('New Invoice'),
        backgroundColor: ColorStyles.white,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: ColorStyles.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    _buildTextField('Invoice Number', 'INV-001'),
                    SizedBox(height: 16.r),
                    _buildTextField('Client Name', 'Select client'),
                    SizedBox(height: 16.r),
                    _buildTextField('Amount', '\$0.00'),
                    SizedBox(height: 16.r),
                    _buildTextField('Due Date', 'Select date'),
                  ],
                ),
              ),
              SizedBox(height: 24.r),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: ColorStyles.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Save Invoice',
                      style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.white),
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

  Widget _buildTextField(String label, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.secondary)),
        SizedBox(height: 8.r),
        CupertinoTextField(
          placeholder: placeholder,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: ColorStyles.fillsTertiary,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ],
    );
  }
}
