import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../data/database.dart';
import '../../../../style/style.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  String _selectedPeriod = 'week';
  List<Invoice> _invoices = [];

  final Map<String, String> _periods = {'week': 'Week', 'month': 'Month', 'year': 'Year'};

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final invoices = await AppDatabase.instance.getAllInvoices();
    setState(() {
      _invoices = invoices;
    });
  }

  DateTime _getPeriodStart() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'week':
        return now.subtract(Duration(days: now.weekday - 1));
      case 'month':
        return DateTime(now.year, now.month, 1);
      case 'year':
        return DateTime(now.year, 1, 1);
      default:
        return now.subtract(Duration(days: now.weekday - 1));
    }
  }

  DateTime _getPeriodEnd() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'week':
        return now.add(Duration(days: 7 - now.weekday));
      case 'month':
        return DateTime(now.year, now.month + 1, 0);
      case 'year':
        return DateTime(now.year, 12, 31);
      default:
        return now.add(Duration(days: 7 - now.weekday));
    }
  }

  List<Invoice> _getFilteredInvoices() {
    final start = _getPeriodStart();
    final end = _getPeriodEnd();
    return _invoices.where((invoice) {
      return invoice.invoiceDate.isAfter(start.subtract(Duration(days: 1))) &&
          invoice.invoiceDate.isBefore(end.add(Duration(days: 1)));
    }).toList();
  }

  double _getTotalIncome() {
    return _getFilteredInvoices()
        .where((i) => i.status == 'paid')
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }

  double _getPaidAmount() {
    return _getFilteredInvoices()
        .where((i) => i.status == 'paid')
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }

  double _getPendingAmount() {
    return _getFilteredInvoices()
        .where((i) => i.status == 'pending')
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }

  double _getOverdueAmount() {
    return _getFilteredInvoices()
        .where((i) => i.status == 'overdue')
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }

  int _getInvoiceCount() {
    return _getFilteredInvoices().length;
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'week':
        return 'This week';
      case 'month':
        return 'This month';
      case 'year':
        return 'This year';
      default:
        return 'This week';
    }
  }

  Map<String, double> _getDailyIncome() {
    final filtered = _getFilteredInvoices().where((i) => i.status == 'paid').toList();
    final Map<String, double> dailyIncome = {};

    if (_selectedPeriod == 'week') {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final dayName = DateFormat('E').format(date);
        dailyIncome[dayName] = 0.0;
      }

      for (var invoice in filtered) {
        final dayName = DateFormat('E').format(invoice.invoiceDate);
        dailyIncome[dayName] = (dailyIncome[dayName] ?? 0.0) + invoice.totalAmount;
      }
    }

    return dailyIncome;
  }

  Map<String, double> _getTopClients() {
    final filtered = _getFilteredInvoices().where((i) => i.status == 'paid').toList();
    final Map<String, double> clientTotals = {};

    for (var invoice in filtered) {
      clientTotals[invoice.clientName] =
          (clientTotals[invoice.clientName] ?? 0.0) + invoice.totalAmount;
    }

    final sorted = clientTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sorted.take(5));
  }

  String _getClientInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _getTotalIncome();
    final paidAmount = _getPaidAmount();
    final pendingAmount = _getPendingAmount();
    final overdueAmount = _getOverdueAmount();
    final invoiceCount = _getInvoiceCount();
    final dailyIncome = _getDailyIncome();
    final topClients = _getTopClients();
    final maxIncome =
        dailyIncome.values.isEmpty ? 1.0 : dailyIncome.values.reduce((a, b) => a > b ? a : b);

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
                Text('Analytics', style: TextStyles.largeTitleEmphasized),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnimatedSegmentedControl(
                    segments: _periods,
                    selectedValue: _selectedPeriod,
                    onValueChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedPeriod = value);
                    },
                  ),
                  SizedBox(height: 16.r),
                  // Total Income Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: ColorStyles.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Income',
                          style: TextStyles.footnoteRegular.copyWith(
                            color: ColorStyles.white.withValues(alpha: 0.8),
                          ),
                        ),
                        SizedBox(height: 8.r),
                        Text(
                          '£${totalIncome.toStringAsFixed(2)}',
                          style: TextStyles.largeTitleEmphasized.copyWith(
                            color: ColorStyles.white,
                            fontSize: 32.sp,
                          ),
                        ),
                        SizedBox(height: 4.r),
                        Text(
                          _getPeriodLabel(),
                          style: TextStyles.footnoteRegular.copyWith(
                            color: ColorStyles.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.r),
                  // Metric Cards
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: CupertinoIcons.checkmark_circle_fill,
                          value: '£${paidAmount.toStringAsFixed(0)}',
                          label: 'Paid',
                          iconColor: ColorStyles.primary,
                        ),
                      ),
                      SizedBox(width: 12.r),
                      Expanded(
                        child: _MetricCard(
                          icon: CupertinoIcons.clock_fill,
                          value: '£${pendingAmount.toStringAsFixed(0)}',
                          label: 'Pending',
                          iconColor: ColorStyles.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.r),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: CupertinoIcons.exclamationmark_circle_fill,
                          value: '£${overdueAmount.toStringAsFixed(0)}',
                          label: 'Overdue',
                          iconColor: ColorStyles.primary,
                          isSquare: true,
                        ),
                      ),
                      SizedBox(width: 12.r),
                      Expanded(
                        child: _MetricCard(
                          icon: CupertinoIcons.doc_text_fill,
                          value: invoiceCount.toString(),
                          label: 'Invoices',
                          iconColor: ColorStyles.primary,
                          isSquare: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.r),
                  // Income Overview
                  Text('Income Overview', style: TextStyles.title3Emphasized),
                  SizedBox(height: 16.r),
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: ColorStyles.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child:
                        _selectedPeriod == 'week'
                            ? Column(
                              children: [
                                SizedBox(
                                  height: 120.r,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children:
                                        dailyIncome.entries.map((entry) {
                                          final height =
                                              maxIncome > 0
                                                  ? (entry.value / maxIncome) * 100.r
                                                  : 0.0;
                                          return Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 4.r),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    height: height,
                                                    decoration: BoxDecoration(
                                                      color: ColorStyles.primary,
                                                      borderRadius: BorderRadius.vertical(
                                                        top: Radius.circular(4.r),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 8.r),
                                                  Text(
                                                    entry.key,
                                                    style: TextStyles.caption1Regular.copyWith(
                                                      color: ColorStyles.secondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ],
                            )
                            : SizedBox(
                              height: 120.r,
                              child: Center(
                                child: Text(
                                  'Chart available for week view',
                                  style: TextStyles.bodyRegular.copyWith(
                                    color: ColorStyles.secondary,
                                  ),
                                ),
                              ),
                            ),
                  ),
                  if (topClients.isNotEmpty) ...[
                    SizedBox(height: 24.r),
                    Text('Top Clients', style: TextStyles.title3Emphasized),
                    SizedBox(height: 16.r),
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: ColorStyles.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children:
                            topClients.entries.map((entry) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 16.r),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40.r,
                                      height: 40.r,
                                      decoration: BoxDecoration(
                                        color: ColorStyles.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getClientInitials(entry.key),
                                          style: TextStyles.footnoteEmphasized.copyWith(
                                            color: ColorStyles.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.r),
                                    Expanded(
                                      child: Text(
                                        entry.key,
                                        style: TextStyles.bodyRegular,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '£${entry.value.toStringAsFixed(0)}',
                                      style: TextStyles.bodyEmphasized,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                  SizedBox(height: 100.r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSegmentedControl extends StatelessWidget {
  final Map<String, String> segments;
  final String selectedValue;
  final ValueChanged<String> onValueChanged;

  const _AnimatedSegmentedControl({
    required this.segments,
    required this.selectedValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.r,
      decoration: BoxDecoration(
        color: ColorStyles.searchBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children:
            segments.entries.map((entry) {
              final isSelected = selectedValue == entry.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onValueChanged(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.all(2.r),
                    decoration: BoxDecoration(
                      color: isSelected ? ColorStyles.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(6.r),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: ColorStyles.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        entry.value,
                        style: TextStyles.footnoteEmphasized.copyWith(
                          color: isSelected ? ColorStyles.primaryTxt : ColorStyles.secondary,
                        ),
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

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final bool isSquare;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    this.isSquare = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ColorStyles.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
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
          Text(value, style: TextStyles.title3Emphasized),
          SizedBox(height: 4.r),
          Text(label, style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.secondary)),
        ],
      ),
    );
  }
}
