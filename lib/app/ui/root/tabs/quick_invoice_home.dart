import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../data/database.dart';
import '../../../../style/style.dart';
import 'quick_invoice_create_invoice.dart';
import 'quick_invoice_details.dart';

String getCurrencySymbol(String code) {
  switch (code) {
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'JPY':
      return '¥';
    case 'CNY':
      return '¥';
    case 'RUB':
      return '₽';
    case 'CAD':
      return 'C\$';
    case 'AUD':
      return 'A\$';
    default:
      return code;
  }
}

class QuickInvoiceHomeTab extends StatefulWidget {
  const QuickInvoiceHomeTab({super.key});

  @override
  State<QuickInvoiceHomeTab> createState() => _QuickInvoiceHomeTabState();
}

class _QuickInvoiceHomeTabState extends State<QuickInvoiceHomeTab> {
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedCurrency = '';
  final _searchController = TextEditingController();
  List<Invoice> _invoices = [];
  List<Invoice> _filteredInvoices = [];
  List<String> _currencies = [];

  final Map<String, String> _statuses = {
    'all': 'All',
    'paid': 'Paid',
    'pending': 'Pending',
    'overdue': 'Overdue',
    'draft': 'Draft',
  };

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final invoices = await AppDatabase.instance.getAllInvoices();
    final currencies = invoices.map((i) => i.currency).toSet().toList();
    setState(() {
      _invoices = invoices;
      _currencies = currencies;
      if (_selectedCurrency.isEmpty && currencies.isNotEmpty) {
        _selectedCurrency = currencies.first;
      }
      _filterInvoices();
    });
  }

  void _filterInvoices() {
    var filtered = _invoices;
    if (_selectedStatus != 'all') {
      filtered = filtered.where((i) => i.status == _selectedStatus).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (i) =>
                i.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                i.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    setState(() => _filteredInvoices = filtered);
  }

  double _getPaidTotal() {
    return _invoices
        .where((i) => i.status == 'paid' && i.currency == _selectedCurrency)
        .fold(0.0, (sum, i) => sum + i.totalAmount);
  }

  double _getPendingTotal() {
    return _invoices
        .where((i) => i.status == 'pending' && i.currency == _selectedCurrency)
        .fold(0.0, (sum, i) => sum + i.totalAmount);
  }

  double _getOverdueTotal() {
    return _invoices
        .where((i) => i.status == 'overdue' && i.currency == _selectedCurrency)
        .fold(0.0, (sum, i) => sum + i.totalAmount);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      child: Column(
        children: [
          Container(
            color: ColorStyles.white,
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 16.r),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Invoices', style: TextStyles.largeTitleEmphasized),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _navigateToCreateInvoice,
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
                  controller: _searchController,
                  placeholder: 'Search invoices...',
                  style: TextStyles.bodyRegular,
                  placeholderStyle: TextStyles.bodyRegular.copyWith(
                    color: ColorStyles.labelsTertiary,
                  ),
                  backgroundColor: ColorStyles.fillsTertiary,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _filterInvoices();
                  },
                ),
                SizedBox(height: 12.r),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Overview', style: TextStyles.title3Emphasized),
                                SizedBox(width: 12.r),
                                if (_currencies.length > 1)
                                  Expanded(
                                    child: SizedBox(
                                      height: 28.r,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _currencies.length,
                                        separatorBuilder: (_, _) => SizedBox(width: 6.r),
                                        itemBuilder: (context, index) {
                                          final currency = _currencies[index];
                                          final isSelected = currency == _selectedCurrency;
                                          return GestureDetector(
                                            onTap: () {
                                              HapticFeedback.selectionClick();
                                              setState(() => _selectedCurrency = currency);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10.r),
                                              decoration: BoxDecoration(
                                                color: isSelected ? ColorStyles.primary : ColorStyles.white,
                                                borderRadius: BorderRadius.circular(14.r),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  currency,
                                                  style: TextStyles.caption1Regular.copyWith(
                                                    color: isSelected ? ColorStyles.white : ColorStyles.primaryTxt,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 12.r),
                            Row(
                              children: [
                                Expanded(
                                  child: _OverviewCard(
                                    label: 'Paid',
                                    amount: _getPaidTotal(),
                                    currency: _selectedCurrency,
                                  ),
                                ),
                                SizedBox(width: 12.r),
                                Expanded(
                                  child: _OverviewCard(
                                    label: 'Pending',
                                    amount: _getPendingTotal(),
                                    currency: _selectedCurrency,
                                  ),
                                ),
                                SizedBox(width: 12.r),
                                Expanded(
                                  child: _OverviewCard(
                                    label: 'Overdue',
                                    amount: _getOverdueTotal(),
                                    currency: _selectedCurrency,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _statuses.entries.map((entry) {
                              final isSelected = _selectedStatus == entry.key;
                              return Padding(
                                padding: EdgeInsets.only(right: 8.r),
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedStatus = entry.key);
                                    _filterInvoices();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? ColorStyles.primary
                                          : ColorStyles.fillsTertiary,
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      entry.value,
                                      style: TextStyles.footnoteEmphasized.copyWith(
                                        color: isSelected
                                            ? ColorStyles.white
                                            : ColorStyles.primaryTxt,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    if (_filteredInvoices.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 80.r),
                            child: Text(
                              _searchQuery.isNotEmpty ? 'No invoices found' : 'No invoices',
                              style: TextStyles.bodyRegular.copyWith(color: ColorStyles.secondary),
                            ),
                          ),
                        ),
                      )
                    else ...[
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _InvoiceWidget(
                              invoice: _filteredInvoices[index],
                              onTap: () => _navigateToInvoiceDetails(_filteredInvoices[index]),
                            ),
                            childCount: _filteredInvoices.length,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 80.r)),
                    ],
                  ],
                ),
                Positioned(
                  left: 16.r,
                  right: 16.r,
                  bottom: 12.r,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _navigateToCreateInvoice(),
                    child: Container(
                      width: double.infinity,
                      height: 50.r,
                      decoration: BoxDecoration(
                        color: ColorStyles.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.add, color: ColorStyles.white, size: 20.r),
                          SizedBox(width: 8.r),
                          Text(
                            'New Invoice',
                            style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateInvoice() async {
    HapticFeedback.selectionClick();
    final result = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<bool>(CupertinoPageRoute(builder: (_) => const QuickInvoiceCreateInvoicePage()));
    if (result == true) _loadInvoices();
  }

  void _navigateToInvoiceDetails(Invoice invoice) {
    HapticFeedback.selectionClick();
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => QuickInvoiceInvoiceDetailsPage(invoice: invoice, onUpdate: _loadInvoices),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;

  const _OverviewCard({required this.label, required this.amount, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: ColorStyles.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyles.caption1Regular.copyWith(color: ColorStyles.secondary)),
          SizedBox(height: 4.r),
          Text(
            '${getCurrencySymbol(currency)}${amount.toStringAsFixed(0)}',
            style: TextStyles.bodyEmphasized,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InvoiceWidget extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;

  const _InvoiceWidget({required this.invoice, required this.onTap});

  Color _getStatusColor() {
    switch (invoice.status) {
      case 'paid':
        return ColorStyles.green;
      case 'pending':
        return ColorStyles.orange;
      case 'overdue':
        return ColorStyles.pink;
      default:
        return ColorStyles.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.r),
      decoration: BoxDecoration(
        color: ColorStyles.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.invoiceNumber,
                          style: TextStyles.footnoteEmphasized.copyWith(
                            color: ColorStyles.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.r),
                        Text(
                          invoice.itemName.isNotEmpty ? invoice.itemName : invoice.clientName,
                          style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.primaryTxt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 4.r),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      invoice.status.substring(0, 1).toUpperCase() + invoice.status.substring(1),
                      style: TextStyles.caption1Regular.copyWith(color: _getStatusColor()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.r),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, yyyy').format(invoice.dueDate),
                    style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.secondary),
                  ),
                  Text(
                    '${getCurrencySymbol(invoice.currency)}${invoice.totalAmount.toStringAsFixed(2)}',
                    style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.primaryTxt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
