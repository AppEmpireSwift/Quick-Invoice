import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../data/database.dart';
import '../../../../style/style.dart';
import '../../../services/pdf_service.dart';
import 'clients.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _searchQuery = '';
  String _selectedStatus = 'all';
  final _searchController = TextEditingController();
  List<Invoice> _invoices = [];
  List<Invoice> _filteredInvoices = [];

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
    setState(() {
      _invoices = invoices;
      _filterInvoices();
    });
  }

  void _filterInvoices() {
    var filtered = _invoices;

    if (_selectedStatus != 'all') {
      filtered = filtered.where((i) => i.status == _selectedStatus).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
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
        .where((i) => i.status == 'paid')
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }

  double _getPendingTotal() {
    return _invoices
        .where((i) => i.status == 'pending')
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }

  double _getOverdueTotal() {
    return _invoices
        .where((i) => i.status == 'overdue')
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
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
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: ColorStyles.white,
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50.r),
                  Text('Invoices', style: TextStyles.largeTitleEmphasized),
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
                ],
              ),
            ),
          ),
          // Overview Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: TextStyles.title3Emphasized),
                  SizedBox(height: 12.r),
                  Row(
                    children: [
                      Expanded(
                        child: _OverviewCard(
                          label: 'Paid',
                          amount: _getPaidTotal(),
                          currency: _invoices.isNotEmpty ? _invoices.first.currency : 'GBP',
                        ),
                      ),
                      SizedBox(width: 12.r),
                      Expanded(
                        child: _OverviewCard(
                          label: 'Pending',
                          amount: _getPendingTotal(),
                          currency: _invoices.isNotEmpty ? _invoices.first.currency : 'GBP',
                        ),
                      ),
                      SizedBox(width: 12.r),
                      Expanded(
                        child: _OverviewCard(
                          label: 'Overdue',
                          amount: _getOverdueTotal(),
                          currency: _invoices.isNotEmpty ? _invoices.first.currency : 'GBP',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Filter Tabs
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      _statuses.entries.map((entry) {
                        final isSelected = _selectedStatus == entry.key;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.r),
                          child: CupertinoButton(
                            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedStatus = entry.key);
                              _filterInvoices();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                              decoration: BoxDecoration(
                                color: isSelected ? ColorStyles.primary : ColorStyles.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: isSelected ? ColorStyles.primary : ColorStyles.separator,
                                ),
                              ),
                              child: Text(
                                entry.value,
                                style: TextStyles.footnoteEmphasized.copyWith(
                                  color: isSelected ? ColorStyles.white : ColorStyles.primaryTxt,
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
              child: _EmptyStateWidget(
                message:
                    _searchQuery.isNotEmpty
                        ? 'No invoices found for "$_searchQuery"'
                        : 'You don\'t have any invoices yet',
                subtitle:
                    _searchQuery.isNotEmpty
                        ? 'Try adjusting your search'
                        : 'Create your first invoice to get started',
                action:
                    _searchQuery.isNotEmpty
                        ? CupertinoButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _filterInvoices();
                          },
                          child: Text(
                            'Clear Search',
                            style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.primary),
                          ),
                        )
                        : CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _navigateToCreateInvoice(),
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
                                'Create invoice',
                                style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.white),
                              ),
                            ),
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
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 92.r, left: 16.r, right: 16.r, top: 16.r),
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
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToCreateInvoice() async {
    HapticFeedback.selectionClick();
    final result = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<bool>(CupertinoPageRoute(builder: (_) => const CreateInvoicePage()));
    if (result == true) {
      _loadInvoices();
    }
  }

  void _navigateToInvoiceDetails(Invoice invoice) {
    HapticFeedback.selectionClick();
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => InvoiceDetailsPage(invoice: invoice, onUpdate: _loadInvoices),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  const _EmptyStateWidget({required this.message, this.subtitle, this.icon, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? CupertinoIcons.doc_text, size: 64.r, color: ColorStyles.secondary),
            SizedBox(height: 16.r),
            Text(message, textAlign: TextAlign.center, style: TextStyles.title3Emphasized),
            if (subtitle != null) ...[
              SizedBox(height: 8.r),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyles.bodyRegular.copyWith(color: ColorStyles.secondary),
              ),
            ],
            if (action != null) ...[SizedBox(height: 24.r), action!],
          ],
        ),
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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ColorStyles.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.secondary)),
          SizedBox(height: 8.r),
          Text('$currency ${amount.toStringAsFixed(0)}', style: TextStyles.title3Emphasized),
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

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
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
                    _formatDate(invoice.dueDate),
                    style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.secondary),
                  ),
                  Text(
                    '${invoice.currency} ${invoice.totalAmount.toStringAsFixed(2)}',
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

class SelectClientPage extends StatefulWidget {
  final Function(Client?)? onClientSelected;

  const SelectClientPage({super.key, this.onClientSelected});

  @override
  State<SelectClientPage> createState() => _SelectClientPageState();
}

class _SelectClientPageState extends State<SelectClientPage> {
  List<Client> _clients = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await AppDatabase.instance.getAllClients();
    setState(() {
      _clients = clients;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Select Client'),
        backgroundColor: ColorStyles.white,
        automaticBackgroundVisibility: false,
        transitionBetweenRoutes: false,
        border: null,
      ),
      child: SafeArea(
        child:
            _clients.isEmpty
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120.r,
                      height: 120.r,
                      decoration: BoxDecoration(
                        color: ColorStyles.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.person_2_fill,
                        size: 60.r,
                        color: ColorStyles.primary,
                      ),
                    ),
                    SizedBox(height: 24.r),
                    Text('No clients yet', style: TextStyles.title3Emphasized),
                    SizedBox(height: 8.r),
                    Text(
                      'Add your first client',
                      style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.secondary),
                    ),
                    SizedBox(height: 32.r),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true)
                            .push(CupertinoPageRoute(builder: (_) => const AddClientPage()))
                            .then((_) => _loadClients());
                      },
                      child: Container(
                        width: 200.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: ColorStyles.primary,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            'Add Client',
                            style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                : ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: _clients.length,
                  itemBuilder: (context, index) {
                    final client = _clients[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.r),
                      decoration: BoxDecoration(
                        color: ColorStyles.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: CupertinoButton(
                        padding: EdgeInsets.all(16.r),
                        onPressed: () {
                          widget.onClientSelected?.call(client);
                          Navigator.pop(context);
                        },
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
                                  client.name.isNotEmpty
                                      ? client.name.substring(0, 1).toUpperCase()
                                      : 'C',
                                  style: TextStyles.footnoteEmphasized.copyWith(
                                    color: ColorStyles.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.r),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(client.name, style: TextStyles.bodyEmphasized),
                                  if (client.phoneNumber.isNotEmpty) ...[
                                    SizedBox(height: 4.r),
                                    Text(
                                      client.phoneNumber,
                                      style: TextStyles.footnoteRegular.copyWith(
                                        color: ColorStyles.secondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              CupertinoIcons.chevron_right,
                              color: ColorStyles.secondary,
                              size: 18.r,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}

class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  int _currentStep = 0; // 0: Details, 1: Items, 2: Review

  final invoiceNumberController = TextEditingController();
  DateTime? invoiceDate;
  DateTime? dueDate;
  final currencyController = TextEditingController(text: 'GBP');
  Client? selectedClient;
  final clientNameController = TextEditingController();
  final clientPhoneController = TextEditingController();
  final itemDescriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final taxController = TextEditingController(text: '0');
  String status = 'pending';
  final noteController = TextEditingController();

  double get subtotal {
    final price = double.tryParse(priceController.text) ?? 0;
    final quantity = int.tryParse(quantityController.text) ?? 0;
    return price * quantity;
  }

  double get taxAmount {
    final tax = double.tryParse(taxController.text) ?? 0;
    return subtotal * (tax / 100);
  }

  double get total => subtotal + taxAmount;

  @override
  void initState() {
    super.initState();
    invoiceDate = DateTime.now();
    dueDate = DateTime.now().add(Duration(days: 30));
    priceController.addListener(() => setState(() {}));
    quantityController.addListener(() => setState(() {}));
    taxController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    invoiceNumberController.dispose();
    currencyController.dispose();
    clientNameController.dispose();
    clientPhoneController.dispose();
    itemDescriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    taxController.dispose();
    noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Future<void> _selectClient() async {
    await Navigator.of(context, rootNavigator: true).push<Client?>(
      CupertinoPageRoute(
        builder:
            (_) => SelectClientPage(
              onClientSelected: (client) {
                if (client != null) {
                  setState(() {
                    selectedClient = client;
                    clientNameController.text = client.name;
                    clientPhoneController.text = client.phoneNumber;
                  });
                }
              },
            ),
      ),
    );
  }

  void _showDatePicker(bool isInvoiceDate) async {
    final today = DateTime.now();
    await showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => Container(
            height: 300.r,
            padding: EdgeInsets.only(top: 6.r),
            decoration: BoxDecoration(
              color: ColorStyles.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      CupertinoButton(
                        child: const Text('Done'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime:
                          isInvoiceDate ? invoiceDate ?? today : dueDate ?? invoiceDate ?? today,
                      minimumDate: isInvoiceDate ? null : invoiceDate,
                      maximumDate: isInvoiceDate ? today : null,
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() {
                          if (isInvoiceDate) {
                            invoiceDate = newDate;
                            if (dueDate != null && dueDate!.isBefore(newDate)) {
                              dueDate = newDate;
                            }
                          } else {
                            dueDate = newDate;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  bool get isCurrentStepValid {
    switch (_currentStep) {
      case 0:
        return invoiceNumberController.text.isNotEmpty && invoiceDate != null && dueDate != null;
      case 1:
        return clientNameController.text.isNotEmpty &&
            itemDescriptionController.text.isNotEmpty &&
            priceController.text.isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  Future<void> _handleSave() async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final invoice = InvoicesCompanion.insert(
      id: id,
      invoiceNumber: invoiceNumberController.text,
      invoiceDate: invoiceDate!,
      dueDate: dueDate!,
      currency: Value(currencyController.text),
      clientName: Value(clientNameController.text),
      clientPhoneNumber: Value(clientPhoneController.text),
      itemName: Value(itemDescriptionController.text),
      itemPrice: Value(double.tryParse(priceController.text) ?? 0),
      itemQuantity: Value(int.tryParse(quantityController.text) ?? 1),
      tax: Value(double.tryParse(taxController.text) ?? 0),
      status: Value(status),
      totalAmount: Value(total),
      note: Value(noteController.text),
    );

    await AppDatabase.instance.insertInvoice(invoice);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyles.bodyRegular.copyWith(color: ColorStyles.primary)),
        ),
        middle: Text('New Invoice'),
        backgroundColor: ColorStyles.white,
        automaticBackgroundVisibility: false,
        transitionBetweenRoutes: false,
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: EdgeInsets.all(16.r),
              child: _ProgressIndicator(currentStep: _currentStep),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: IndexedStack(
                  index: _currentStep,
                  children: [_buildDetailsStep(), _buildItemsStep(), _buildReviewStep()],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed:
                    isCurrentStepValid
                        ? () {
                          if (_currentStep < 2) {
                            setState(() => _currentStep++);
                          } else {
                            _handleSave();
                          }
                        }
                        : null,
                child: Container(
                  width: double.infinity,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: isCurrentStepValid ? ColorStyles.primary : ColorStyles.searchBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _currentStep < 2 ? 'Continue' : 'Save',
                    style: TextStyles.bodyEmphasized.copyWith(
                      color: isCurrentStepValid ? ColorStyles.white : ColorStyles.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InputWidget(
          controller: invoiceNumberController,
          label: 'Invoice number',
          placeholder: 'INV-001',
        ),
        SizedBox(height: 16.r),
        _SelectableContainer(
          label: 'Invoice date',
          value: invoiceDate != null ? _formatDate(invoiceDate) : null,
          placeholder: 'Select date',
          onTap: () => _showDatePicker(true),
          icon: Icon(CupertinoIcons.calendar, color: ColorStyles.secondary, size: 20.r),
        ),
        SizedBox(height: 16.r),
        _SelectableContainer(
          label: 'Due date',
          value: dueDate != null ? _formatDate(dueDate) : null,
          placeholder: 'Select date',
          onTap: () => _showDatePicker(false),
          icon: Icon(CupertinoIcons.calendar, color: ColorStyles.secondary, size: 20.r),
        ),
        SizedBox(height: 16.r),
        _SelectableContainer(
          label: 'Currency',
          value: currencyController.text,
          placeholder: 'Select currency',
          onTap: () => _showCurrencyPicker(),
          icon: Icon(CupertinoIcons.money_dollar_circle, color: ColorStyles.secondary, size: 20.r),
        ),
      ],
    );
  }

  void _showCurrencyPicker() {
    final currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY', 'CNY', 'RUB'];
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => Container(
            height: 300.r,
            decoration: BoxDecoration(
              color: ColorStyles.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Currency', style: TextStyles.bodyEmphasized),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: Icon(CupertinoIcons.xmark_circle_fill, color: ColorStyles.secondary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: currencies.length,
                    itemBuilder:
                        (context, index) => CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() => currencyController.text = currencies[index]);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(currencies[index], style: TextStyles.bodyRegular),
                                if (currencyController.text == currencies[index])
                                  Icon(
                                    CupertinoIcons.checkmark,
                                    color: ColorStyles.primary,
                                    size: 20.r,
                                  ),
                              ],
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildItemsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CLIENT',
          style: TextStyles.caption1Regular.copyWith(
            color: ColorStyles.secondary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 16.r),
        Container(
          decoration: BoxDecoration(
            color: ColorStyles.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              CupertinoButton(
                padding: EdgeInsets.all(16.r),
                onPressed: _selectClient,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Client', style: TextStyles.bodyRegular),
                    Row(
                      children: [
                        Text(
                          selectedClient != null ? 'Choose from list' : 'Choose from list',
                          style: TextStyles.bodyRegular.copyWith(color: ColorStyles.primary),
                        ),
                        SizedBox(width: 4.r),
                        Icon(CupertinoIcons.chevron_right, color: ColorStyles.primary, size: 18.r),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, indent: 16.r, color: ColorStyles.separator),
              _InputWidget(
                controller: clientNameController,
                label: 'Client Name',
                placeholder: 'Enter name',
              ),
              Divider(height: 1, indent: 16.r, color: ColorStyles.separator),
              _InputWidget(
                controller: clientPhoneController,
                label: 'Phone',
                placeholder: 'Enter phone',
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        SizedBox(height: 24.r),
        Text(
          'ITEM / SERVICE',
          style: TextStyles.caption1Regular.copyWith(
            color: ColorStyles.secondary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 16.r),
        _InputWidget(
          controller: itemDescriptionController,
          label: 'Description',
          placeholder: 'What are you billing',
        ),
        SizedBox(height: 16.r),
        _InputWidget(
          controller: priceController,
          label: 'Price',
          placeholder: '0.00',
          keyboardType: TextInputType.number,
          suffix: Text('£', style: TextStyles.bodyRegular),
        ),
        SizedBox(height: 16.r),
        _InputWidget(
          controller: quantityController,
          label: 'Quantity',
          placeholder: '1',
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16.r),
        _InputWidget(
          controller: taxController,
          label: 'Tax',
          placeholder: '0',
          keyboardType: TextInputType.number,
          suffix: Text('%', style: TextStyles.bodyRegular),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REVIEW',
          style: TextStyles.caption1Regular.copyWith(
            color: ColorStyles.secondary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 16.r),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: ColorStyles.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow('Invoice Number', invoiceNumberController.text),
              Divider(color: ColorStyles.separator),
              _buildReviewRow('Invoice Date', _formatDate(invoiceDate)),
              Divider(color: ColorStyles.separator),
              _buildReviewRow('Due Date', _formatDate(dueDate)),
              Divider(color: ColorStyles.separator),
              _buildReviewRow('Client', clientNameController.text),
              Divider(color: ColorStyles.separator),
              _buildReviewRow('Description', itemDescriptionController.text),
              Divider(color: ColorStyles.separator),
              _buildReviewRow('Price', '${currencyController.text} ${priceController.text}'),
              Divider(color: ColorStyles.separator),
              _buildReviewRow('Quantity', quantityController.text),
              Divider(color: ColorStyles.separator),
              _buildReviewRow('Tax', '${taxController.text}%'),
              Divider(color: ColorStyles.separator),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: TextStyles.bodyEmphasized),
                  Text(
                    '${currencyController.text} ${total.toStringAsFixed(2)}',
                    style: TextStyles.title3Emphasized.copyWith(color: ColorStyles.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.secondary)),
          Expanded(child: Text(value, style: TextStyles.bodyRegular, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int currentStep;

  const _ProgressIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ProgressStep(
          step: 1,
          label: 'Details',
          isCompleted: currentStep > 0,
          isActive: currentStep == 0,
        ),
        Container(
          width: 40.r,
          height: 2.r,
          color: currentStep > 0 ? ColorStyles.primary : ColorStyles.separator,
        ),
        _ProgressStep(
          step: 2,
          label: 'Items',
          isCompleted: currentStep > 1,
          isActive: currentStep == 1,
        ),
        Container(
          width: 40.r,
          height: 2.r,
          color: currentStep > 1 ? ColorStyles.primary : ColorStyles.separator,
        ),
        _ProgressStep(step: 3, label: 'Review', isCompleted: false, isActive: currentStep == 2),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final int step;
  final String label;
  final bool isCompleted;
  final bool isActive;

  const _ProgressStep({
    required this.step,
    required this.label,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: isCompleted || isActive ? ColorStyles.primary : ColorStyles.separator,
            shape: BoxShape.circle,
          ),
          child: Center(
            child:
                isCompleted
                    ? Icon(CupertinoIcons.checkmark, color: ColorStyles.white, size: 16.r)
                    : Text(
                      step.toString(),
                      style: TextStyles.footnoteEmphasized.copyWith(
                        color: isActive ? ColorStyles.white : ColorStyles.secondary,
                      ),
                    ),
          ),
        ),
        SizedBox(height: 4.r),
        Text(
          label,
          style: TextStyles.caption1Regular.copyWith(
            color: isActive ? ColorStyles.primary : ColorStyles.secondary,
          ),
        ),
      ],
    );
  }
}

class _InputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? suffix;

  const _InputWidget({
    required this.controller,
    this.label,
    this.placeholder,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyles.caption1Regular.copyWith(
              color: ColorStyles.secondary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8.r),
        ],
        Container(
          decoration: BoxDecoration(
            color: ColorStyles.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: ColorStyles.separator, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: controller,
                  style: TextStyles.bodyRegular.copyWith(color: ColorStyles.primaryTxt),
                  placeholder: placeholder ?? label,
                  placeholderStyle: TextStyles.bodyRegular.copyWith(
                    color: ColorStyles.secondary.withValues(alpha: 0.5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
                  decoration: null,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                ),
              ),
              if (suffix != null) ...[
                Padding(padding: EdgeInsets.only(right: 16.r), child: suffix!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectableContainer extends StatelessWidget {
  final String label;
  final String? value;
  final String? placeholder;
  final VoidCallback onTap;
  final Widget? icon;

  const _SelectableContainer({
    required this.label,
    this.value,
    this.placeholder,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 8.r),
            child: Text(
              label,
              style: TextStyles.caption1Regular.copyWith(
                color: ColorStyles.secondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: ColorStyles.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: ColorStyles.separator),
            ),
            child: Row(
              children: [
                if (icon != null) ...[icon!, SizedBox(width: 12.r)],
                Expanded(
                  child: Text(
                    value ?? placeholder ?? 'Select',
                    style: TextStyles.bodyRegular.copyWith(
                      color:
                          value != null
                              ? ColorStyles.primaryTxt
                              : ColorStyles.secondary.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                Icon(CupertinoIcons.chevron_down, color: ColorStyles.secondary, size: 20.r),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class InvoiceDetailsPage extends StatefulWidget {
  final Invoice invoice;
  final VoidCallback onUpdate;

  const InvoiceDetailsPage({super.key, required this.invoice, required this.onUpdate});

  @override
  State<InvoiceDetailsPage> createState() => _InvoiceDetailsPageState();
}

class _InvoiceDetailsPageState extends State<InvoiceDetailsPage> {
  late Invoice invoice;

  @override
  void initState() {
    super.initState();
    invoice = widget.invoice;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

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

  Future<void> _updateStatus(String newStatus) async {
    final updated = InvoicesCompanion(
      id: Value(invoice.id),
      invoiceNumber: Value(invoice.invoiceNumber),
      invoiceDate: Value(invoice.invoiceDate),
      dueDate: Value(invoice.dueDate),
      currency: Value(invoice.currency),
      clientName: Value(invoice.clientName),
      clientPhoneNumber: Value(invoice.clientPhoneNumber),
      itemName: Value(invoice.itemName),
      itemPrice: Value(invoice.itemPrice),
      itemQuantity: Value(invoice.itemQuantity),
      tax: Value(invoice.tax),
      signature: Value(invoice.signature),
      status: Value(newStatus),
      totalAmount: Value(invoice.totalAmount),
      note: Value(invoice.note),
    );

    await AppDatabase.instance.updateInvoice(updated);
    final refreshed = await AppDatabase.instance.getInvoiceById(invoice.id);
    if (refreshed != null && mounted) {
      setState(() => invoice = refreshed);
      widget.onUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: ColorStyles.white.withValues(alpha: 0.9),
              padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 8.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.chevron_back, color: ColorStyles.primary),
                        Text(
                          'Back',
                          style: TextStyles.bodyRegular.copyWith(color: ColorStyles.primary),
                        ),
                      ],
                    ),
                  ),
                  Text('Invoice', style: TextStyles.bodyEmphasized),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showExportOptions(),
                    child: Icon(CupertinoIcons.ellipsis, color: ColorStyles.primary, size: 22.r),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Blue Summary Card
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
                            invoice.invoiceNumber,
                            style: TextStyles.footnoteRegular.copyWith(
                              color: ColorStyles.white.withValues(alpha: 0.9),
                            ),
                          ),
                          SizedBox(height: 8.r),
                          Text(
                            '${invoice.currency} ${invoice.totalAmount.toStringAsFixed(2)}',
                            style: TextStyles.largeTitleEmphasized.copyWith(
                              color: ColorStyles.white,
                              fontSize: 32.sp,
                            ),
                          ),
                          SizedBox(height: 8.r),
                          Text(
                            'Due ${_formatDate(invoice.dueDate)}',
                            style: TextStyles.footnoteRegular.copyWith(
                              color: ColorStyles.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.r),
                    // Status Section
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: ColorStyles.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24.r,
                            height: 24.r,
                            decoration: BoxDecoration(
                              color: _getStatusColor(),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.checkmark,
                              color: ColorStyles.white,
                              size: 14.r,
                            ),
                          ),
                          SizedBox(width: 12.r),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyles.footnoteRegular.copyWith(
                                    color: ColorStyles.secondary,
                                  ),
                                ),
                                SizedBox(height: 2.r),
                                Text(
                                  invoice.status.substring(0, 1).toUpperCase() +
                                      invoice.status.substring(1),
                                  style: TextStyles.bodyEmphasized.copyWith(
                                    color: _getStatusColor(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: invoice.status == 'paid',
                            onChanged: (value) {
                              _updateStatus(value ? 'paid' : 'pending');
                            },
                            activeColor: ColorStyles.green,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.r),
                    // Invoice Details
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: ColorStyles.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Client', invoice.clientName),
                          Divider(color: ColorStyles.separator, height: 24.r),
                          _buildDetailRow('Invoice Date', _formatDate(invoice.invoiceDate)),
                          Divider(color: ColorStyles.separator, height: 24.r),
                          _buildDetailRow('Due Date', _formatDate(invoice.dueDate)),
                          Divider(color: ColorStyles.separator, height: 24.r),
                          _buildDetailRow('Currency', invoice.currency),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.r),
                    // Items Section
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: ColorStyles.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Items', style: TextStyles.bodyEmphasized),
                          SizedBox(height: 16.r),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(invoice.itemName, style: TextStyles.bodyRegular),
                                    SizedBox(height: 4.r),
                                    Text(
                                      '${invoice.itemQuantity} x ${invoice.currency} ${invoice.itemPrice.toStringAsFixed(2)}',
                                      style: TextStyles.footnoteRegular.copyWith(
                                        color: ColorStyles.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${invoice.currency} ${(invoice.itemPrice * invoice.itemQuantity).toStringAsFixed(2)}',
                                style: TextStyles.bodyEmphasized,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.r),
                  ],
                ),
              ),
            ),
            // Bottom Action Buttons
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: ColorStyles.white,
                border: Border(top: BorderSide(color: ColorStyles.separator, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _showTemplateSelector((template) {
                          PdfService.printInvoice(invoice, template: template);
                        });
                      },
                      child: Container(
                        height: 50.r,
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorStyles.primary),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            'Preview',
                            style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.r),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _showTemplateSelector((template) {
                          PdfService.shareInvoice(invoice, template: template);
                        });
                      },
                      child: Container(
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: ColorStyles.primary,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            'Send',
                            style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyles.bodyRegular.copyWith(color: ColorStyles.secondary)),
        Expanded(
          child: Text(
            value,
            style: TextStyles.bodyRegular,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showExportOptions() {
    _showTemplateSelector((template) {
      PdfService.shareInvoice(invoice, template: template);
    });
  }

  void _showTemplateSelector(Function(PdfTemplate) onTemplateSelected) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => _TemplateSelectorModal(
            onTemplateSelected: (template) {
              Navigator.pop(context);
              onTemplateSelected(template);
            },
          ),
    );
  }
}

class _TemplateSelectorModal extends StatefulWidget {
  final Function(PdfTemplate) onTemplateSelected;

  const _TemplateSelectorModal({required this.onTemplateSelected});

  @override
  State<_TemplateSelectorModal> createState() => _TemplateSelectorModalState();
}

class _TemplateSelectorModalState extends State<_TemplateSelectorModal> {
  PdfTemplate _selectedTemplate = PdfTemplate.classic;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorStyles.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.only(top: 8.r, bottom: 16.r),
              width: 40.r,
              height: 4.r,
              decoration: BoxDecoration(
                color: ColorStyles.separator,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              child: Text('Select Template', style: TextStyles.title3Emphasized),
            ),
            SizedBox(height: 24.r),
            // Template options
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              child: Row(
                children: [
                  Expanded(
                    child: _TemplateOption(
                      name: 'Classic',
                      template: PdfTemplate.classic,
                      isSelected: _selectedTemplate == PdfTemplate.classic,
                      onTap: () => setState(() => _selectedTemplate = PdfTemplate.classic),
                    ),
                  ),
                  SizedBox(width: 12.r),
                  Expanded(
                    child: _TemplateOption(
                      name: 'Modern',
                      template: PdfTemplate.modern,
                      isSelected: _selectedTemplate == PdfTemplate.modern,
                      onTap: () => setState(() => _selectedTemplate = PdfTemplate.modern),
                    ),
                  ),
                  SizedBox(width: 12.r),
                  Expanded(
                    child: _TemplateOption(
                      name: 'Minir',
                      template: PdfTemplate.minimal,
                      isSelected: _selectedTemplate == PdfTemplate.minimal,
                      onTap: () => setState(() => _selectedTemplate = PdfTemplate.minimal),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.r),
            // Continue button
            Padding(
              padding: EdgeInsets.all(16.r),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => widget.onTemplateSelected(_selectedTemplate),
                child: Container(
                  width: double.infinity,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: ColorStyles.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Continue',
                      style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateOption extends StatelessWidget {
  final String name;
  final PdfTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateOption({
    required this.name,
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: ColorStyles.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? ColorStyles.primary : ColorStyles.separator,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Template preview placeholder
            Container(
              height: 100.r,
              decoration: BoxDecoration(
                color: ColorStyles.bgSecondary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: _buildTemplatePreview(template),
            ),
            SizedBox(height: 12.r),
            Text(name, style: TextStyles.footnoteEmphasized),
            if (isSelected) ...[
              SizedBox(height: 8.r),
              Icon(CupertinoIcons.checkmark_circle_fill, color: ColorStyles.primary, size: 20.r),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatePreview(PdfTemplate template) {
    switch (template) {
      case PdfTemplate.classic:
        return Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 8.r,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorStyles.primary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 8.r),
              Container(
                height: 20.r,
                width: 40.r,
                decoration: BoxDecoration(
                  color: ColorStyles.separator,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 8.r),
              ...List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 4.r),
                  child: Container(
                    height: 4.r,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ColorStyles.separator,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case PdfTemplate.modern:
        return Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 12.r,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorStyles.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                ),
              ),
              SizedBox(height: 8.r),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 20.r,
                      decoration: BoxDecoration(
                        color: ColorStyles.separator,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.r),
                  Expanded(
                    child: Container(
                      height: 20.r,
                      decoration: BoxDecoration(
                        color: ColorStyles.separator,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.r),
              Container(
                height: 30.r,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorStyles.separator,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ),
        );
      case PdfTemplate.minimal:
        return Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 8.r,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorStyles.black,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 8.r),
              ...List.generate(
                4,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 4.r),
                  child: Container(
                    height: 4.r,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ColorStyles.separator,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
