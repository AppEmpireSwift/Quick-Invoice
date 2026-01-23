import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../data/database.dart';
import '../../../../style/style.dart';
import 'analytics_widgets.dart';

class QuickInvoiceAnalyticsTab extends StatefulWidget {
  const QuickInvoiceAnalyticsTab({super.key});

  @override
  State<QuickInvoiceAnalyticsTab> createState() => QuickInvoiceAnalyticsTabState();
}

class QuickInvoiceAnalyticsTabState extends State<QuickInvoiceAnalyticsTab> {
  String _selectedPeriod = 'week';
  String _selectedCurrency = 'USD';
  List<Invoice> _invoices = [];
  List<Client> _clients = [];
  List<String> _currencies = [];

  final Map<String, String> _periods = {'week': 'Week', 'month': 'Month', 'year': 'Year'};

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    final invoices = await AppDatabase.instance.getAllInvoices();
    final clients = await AppDatabase.instance.getAllClients();
    final currencies = invoices.map((i) => i.currency).toSet().toList();
    if (currencies.isEmpty) currencies.add('USD');
    setState(() {
      _invoices = invoices;
      _clients = clients;
      _currencies = currencies;
      if (!currencies.contains(_selectedCurrency)) {
        _selectedCurrency = currencies.first;
      }
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
      return invoice.currency == _selectedCurrency &&
          invoice.invoiceDate.isAfter(start.subtract(Duration(days: 1))) &&
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

  String _getCurrencySymbol() {
    switch (_selectedCurrency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'RUB':
        return '₽';
      default:
        return _selectedCurrency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sym = _getCurrencySymbol();
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
                  if (_currencies.length > 1) ...[
                    SizedBox(
                      height: 32.r,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _currencies.length,
                        separatorBuilder: (_, _) => SizedBox(width: 8.r),
                        itemBuilder: (context, index) {
                          final currency = _currencies[index];
                          final isSelected = currency == _selectedCurrency;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCurrency = currency);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(horizontal: 16.r),
                              decoration: BoxDecoration(
                                color: isSelected ? ColorStyles.primary : ColorStyles.white,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Center(
                                child: Text(
                                  currency,
                                  style: TextStyles.footnoteEmphasized.copyWith(
                                    color: isSelected ? ColorStyles.white : ColorStyles.primaryTxt,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12.r),
                  ],
                  AnalyticsSegmentedControl(
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
                          '$sym${totalIncome.toStringAsFixed(2)}',
                          style: TextStyles.largeTitleEmphasized.copyWith(
                            color: ColorStyles.white,
                            fontSize: 32.sp.clamp(0, 38),
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
                        child: AnalyticsMetricCard(
                          icon: CupertinoIcons.checkmark_circle_fill,
                          value: '$sym${paidAmount.toStringAsFixed(0)}',
                          label: 'Paid',
                          iconColor: ColorStyles.primary,
                        ),
                      ),
                      SizedBox(width: 12.r),
                      Expanded(
                        child: AnalyticsMetricCard(
                          icon: CupertinoIcons.clock_fill,
                          value: '$sym${pendingAmount.toStringAsFixed(0)}',
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
                        child: AnalyticsMetricCard(
                          icon: CupertinoIcons.exclamationmark_circle_fill,
                          value: '$sym${overdueAmount.toStringAsFixed(0)}',
                          label: 'Overdue',
                          iconColor: ColorStyles.primary,
                          isSquare: true,
                        ),
                      ),
                      SizedBox(width: 12.r),
                      Expanded(
                        child: AnalyticsMetricCard(
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
                                                  ? (entry.value / maxIncome) * 88.r
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
                              final client = _clients.where((c) => c.name == entry.key).firstOrNull;
                              return Padding(
                                  padding: EdgeInsets.only(bottom: 12.r),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36.r,
                                        height: 36.r,
                                        decoration: BoxDecoration(
                                          color: ColorStyles.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipOval(
                                          child:
                                              client?.image != null
                                                  ? Image.memory(
                                                    client!.image!,
                                                    width: 36.r,
                                                    height: 36.r,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Center(
                                                    child: Text(
                                                      entry.key.isNotEmpty
                                                          ? entry.key[0].toUpperCase()
                                                          : 'C',
                                                      style: TextStyles.footnoteEmphasized.copyWith(
                                                        color: ColorStyles.white,
                                                      ),
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
                                        '$sym${entry.value.toStringAsFixed(0)}',
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
