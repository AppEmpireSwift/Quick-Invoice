import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../style/style.dart';

class ClientsTab extends StatelessWidget {
  const ClientsTab({super.key});

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Clients', style: TextStyles.largeTitleEmphasized),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context, rootNavigator: true).push(
                            CupertinoPageRoute(builder: (_) => const AddClientPage()),
                          );
                        },
                        child: Icon(
                          CupertinoIcons.plus_circle_fill,
                          color: ColorStyles.primary,
                          size: 28.r,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.r),
                  CupertinoSearchTextField(
                    placeholder: 'Search clients...',
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
                Icon(CupertinoIcons.person_2, size: 64.r, color: ColorStyles.labelsTertiary),
                SizedBox(height: 16.r),
                Text('No clients yet', style: TextStyles.title3Emphasized),
                SizedBox(height: 8.r),
                Text(
                  'Add your first client',
                  style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.labelsTertiary),
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

class AddClientPage extends StatelessWidget {
  const AddClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      navigationBar: CupertinoNavigationBar(
        middle: Text('New Client'),
        backgroundColor: ColorStyles.white,
        automaticBackgroundVisibility: false,
        transitionBetweenRoutes: false,
        border: null,
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
                    _buildTextField('Name', 'Client name'),
                    SizedBox(height: 16.r),
                    _buildTextField('Email', 'client@email.com'),
                    SizedBox(height: 16.r),
                    _buildTextField('Phone', '+1 234 567 890'),
                    SizedBox(height: 16.r),
                    _buildTextField('Address', 'Client address'),
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
                      'Save Client',
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
