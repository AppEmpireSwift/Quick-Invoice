import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../style/style.dart';
import 'tabs/home.dart';
import 'tabs/clients.dart';
import 'tabs/analytics.dart';
import 'tabs/settings.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                HomeTab(),
                ClientsTab(),
                AnalyticsTab(),
                SettingsTab(),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: ColorStyles.white,
              boxShadow: [
                BoxShadow(
                  color: ColorStyles.black.withValues(alpha: 0.08),
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
                  _buildTabItem(0, CupertinoIcons.doc_text_fill, 'Invoices'),
                  _buildTabItem(1, CupertinoIcons.person_2_fill, 'Clients'),
                  _buildTabItem(2, CupertinoIcons.chart_bar_fill, 'Analytics'),
                  _buildTabItem(3, CupertinoIcons.settings, 'Settings'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? ColorStyles.primary : CupertinoColors.systemGrey2,
            size: 24.r,
          ),
          SizedBox(height: 2.r),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color:
                  isActive ? ColorStyles.primary : CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}
