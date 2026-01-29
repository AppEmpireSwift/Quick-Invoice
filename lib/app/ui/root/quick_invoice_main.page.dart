import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../style/quick_invoice_style.dart';
import 'tabs/quick_invoice_home.dart';
import 'tabs/quick_invoice_clients.dart';
import 'tabs/quick_invoice_analytics.dart';
import 'tabs/quick_invoice_settings.dart';

class QuickInvoiceMainPage extends StatefulWidget {
  const QuickInvoiceMainPage({super.key});

  @override
  State<QuickInvoiceMainPage> createState() => _QuickInvoiceMainPageState();
}

class _QuickInvoiceMainPageState extends State<QuickInvoiceMainPage> {
  int _currentIndex = 0;
  final _analyticsKey = GlobalKey<QuickInvoiceAnalyticsTabState>();

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    if (index == 2) _analyticsKey.currentState?.loadInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: QuickInvoiceColorStyles.bgSecondary,
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                const QuickInvoiceHomeTab(),
                const QuickInvoiceClientsTab(),
                QuickInvoiceAnalyticsTab(key: _analyticsKey),
                const QuickInvoiceSettingsTab(),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: QuickInvoiceColorStyles.white,
              boxShadow: [
                BoxShadow(
                  color: QuickInvoiceColorStyles.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              height: 60.r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _TabItem(
                    isActive: _currentIndex == 0,
                    icon: CupertinoIcons.doc_text_fill,
                    label: 'Invoices',
                    onTap: () => _onTabChanged(0),
                  ),
                  _TabItem(
                    isActive: _currentIndex == 1,
                    icon: CupertinoIcons.person_2_fill,
                    label: 'Clients',
                    onTap: () => _onTabChanged(1),
                  ),
                  _TabItem(
                    isActive: _currentIndex == 2,
                    icon: CupertinoIcons.chart_bar_fill,
                    label: 'Analytics',
                    onTap: () => _onTabChanged(2),
                  ),
                  _TabItem(
                    isActive: _currentIndex == 3,
                    icon: CupertinoIcons.settings,
                    label: 'Settings',
                    onTap: () => _onTabChanged(3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final bool isActive;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TabItem({
    required this.isActive,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? QuickInvoiceColorStyles.primary : CupertinoColors.systemGrey2,
            size: 24.r,
          ),
          SizedBox(height: 2.r),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp.clamp(0, 16),
              fontWeight: FontWeight.w500,
              color: isActive ? QuickInvoiceColorStyles.primary : CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}
