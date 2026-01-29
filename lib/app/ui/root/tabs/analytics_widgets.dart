import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../data/database.dart';
import '../../../../style/quick_invoice_style.dart';

class AnalyticsSegmentedControl extends StatelessWidget {
  final Map<String, String> segments;
  final String selectedValue;
  final ValueChanged<String> onValueChanged;

  const AnalyticsSegmentedControl({super.key, required this.segments, required this.selectedValue, required this.onValueChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.r,
      decoration: BoxDecoration(color: QuickInvoiceColorStyles.searchBg, borderRadius: BorderRadius.circular(8.r)),
      child: Row(
        children: segments.entries.map((entry) {
          final isSelected = selectedValue == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  color: isSelected ? QuickInvoiceColorStyles.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.r),
                  boxShadow: isSelected
                      ? [BoxShadow(color: QuickInvoiceColorStyles.black.withValues(alpha: 0.1), blurRadius: 4, offset: Offset(0, 2))]
                      : null,
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: QuickInvoiceTextStyles.footnoteEmphasized.copyWith(color: isSelected ? QuickInvoiceColorStyles.primaryTxt : QuickInvoiceColorStyles.secondary),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AnalyticsMetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final bool isSquare;

  const AnalyticsMetricCard({super.key, required this.icon, required this.value, required this.label, required this.iconColor, this.isSquare = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: QuickInvoiceColorStyles.white, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: isSquare ? BorderRadius.circular(8.r) : null,
            ),
            child: Icon(icon, color: iconColor, size: 20.r),
          ),
          SizedBox(height: 12.r),
          Text(value, style: QuickInvoiceTextStyles.title3Emphasized, maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: 4.r),
          Text(label, style: QuickInvoiceTextStyles.footnoteRegular.copyWith(color: QuickInvoiceColorStyles.secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class AnalyticsClientInfoSheet extends StatelessWidget {
  final Client client;

  const AnalyticsClientInfoSheet({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: QuickInvoiceColorStyles.white,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Client'),
        backgroundColor: QuickInvoiceColorStyles.white,
        transitionBetweenRoutes: false,
        automaticBackgroundVisibility: false,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(CupertinoIcons.xmark, size: 20.r, color: QuickInvoiceColorStyles.secondary),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              SizedBox(height: 16.r),
              Text(client.name, style: QuickInvoiceTextStyles.title3Emphasized, textAlign: TextAlign.center),
              SizedBox(height: 24.r),
              if (client.email.isNotEmpty) _infoRow('Email', client.email),
              if (client.phoneNumber.isNotEmpty) _infoRow('Phone', client.phoneNumber),
              if (client.address.isNotEmpty) _infoRow('Address', client.address),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.r),
      child: Row(
        children: [
          Text(label, style: QuickInvoiceTextStyles.bodyRegular.copyWith(color: QuickInvoiceColorStyles.secondary)),
          SizedBox(width: 16.r),
          Expanded(child: Text(value, style: QuickInvoiceTextStyles.bodyRegular, textAlign: TextAlign.end, maxLines: 2, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
