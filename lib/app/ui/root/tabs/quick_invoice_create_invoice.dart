import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../data/database.dart';
import '../../../../style/style.dart';
import '../../../services/premium_limits.dart';
import '../../premium/quick_invoice_main_paywall.page.dart';
import 'quick_invoice_home.dart';
import 'quick_invoice_select_client.dart';

class QuickInvoiceCreateInvoicePage extends StatefulWidget {
  final Invoice? editInvoice;

  const QuickInvoiceCreateInvoicePage({super.key, this.editInvoice});

  @override
  State<QuickInvoiceCreateInvoicePage> createState() => _QuickInvoiceCreateInvoicePageState();
}

class _QuickInvoiceCreateInvoicePageState extends State<QuickInvoiceCreateInvoicePage> {
  int _currentStep = 0;
  final invoiceNumberController = TextEditingController();
  DateTime? invoiceDate;
  DateTime? dueDate;
  final currencyController = TextEditingController();
  Client? selectedClient;
  final clientNameController = TextEditingController();
  final clientPhoneController = TextEditingController();
  final itemDescriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final taxController = TextEditingController();
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
    final edit = widget.editInvoice;
    if (edit != null) {
      invoiceNumberController.text = edit.invoiceNumber;
      invoiceDate = edit.invoiceDate;
      dueDate = edit.dueDate;
      currencyController.text = edit.currency;
      clientNameController.text = edit.clientName;
      clientPhoneController.text = edit.clientPhoneNumber;
      itemDescriptionController.text = edit.itemName;
      priceController.text = edit.itemPrice > 0 ? edit.itemPrice.toString() : '';
      quantityController.text = edit.itemQuantity > 0 ? edit.itemQuantity.toString() : '';
      taxController.text = edit.tax > 0 ? edit.tax.toString() : '';
      status = edit.status;
      noteController.text = edit.note;
    } else {
      invoiceDate = DateTime.now();
      dueDate = DateTime.now().add(Duration(days: 30));
    }
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
        builder: (_) => QuickInvoiceSelectClientPage(
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
      builder: (BuildContext context) => Container(
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
                  CupertinoButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
                  CupertinoButton(child: const Text('Done'), onPressed: () => Navigator.pop(context)),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: isInvoiceDate ? invoiceDate ?? today : dueDate ?? invoiceDate ?? today,
                  minimumDate: isInvoiceDate ? null : invoiceDate,
                  maximumDate: isInvoiceDate ? today : null,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      if (isInvoiceDate) {
                        invoiceDate = newDate;
                        if (dueDate != null && dueDate!.isBefore(newDate)) dueDate = newDate;
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
        return invoiceNumberController.text.isNotEmpty && invoiceDate != null && dueDate != null && currencyController.text.isNotEmpty;
      case 1:
        return clientNameController.text.isNotEmpty && itemDescriptionController.text.isNotEmpty && priceController.text.isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  Future<void> _handleSave() async {
    final edit = widget.editInvoice;
    if (edit != null) {
      final updated = InvoicesCompanion(
        id: Value(edit.id),
        invoiceNumber: Value(invoiceNumberController.text),
        invoiceDate: Value(invoiceDate!),
        dueDate: Value(dueDate!),
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
      await AppDatabase.instance.updateInvoice(updated);
    } else {
      if (!await PremiumLimits.canCreateInvoice()) {
        if (mounted) QuickInvoiceMainPaywallPage.show(context);
        return;
      }
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
    }
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
        middle: Text(widget.editInvoice != null ? 'Edit Invoice' : 'New Invoice'),
        backgroundColor: ColorStyles.white,
        automaticBackgroundVisibility: false,
        transitionBetweenRoutes: false,
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
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
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(color: ColorStyles.white),
              child: SafeArea(
                top: false,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: isCurrentStepValid
                      ? () {
                          HapticFeedback.selectionClick();
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
                      color: isCurrentStepValid ? ColorStyles.primary : ColorStyles.fillsTertiary,
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
        _InputWidget(controller: invoiceNumberController, label: 'Invoice number', placeholder: 'INV-001'),
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
          value: currencyController.text.isEmpty ? null : currencyController.text,
          placeholder: 'Select currency',
          onTap: () => _showCurrencyPicker(),
          icon: currencyController.text.isEmpty
              ? null
              : Text(getCurrencySymbol(currencyController.text), style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.secondary, fontSize: 20.sp.clamp(0, 26))),
        ),
      ],
    );
  }

  void _showCurrencyPicker() {
    final currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY', 'CNY', 'RUB'];
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 400.h,
        decoration: BoxDecoration(
          color: ColorStyles.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
        ),
        child: SafeArea(
          top: false,
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
                  padding: EdgeInsets.zero,
                  itemCount: currencies.length,
                  itemBuilder: (context, index) => CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() => currencyController.text = currencies[index]);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.r),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(currencies[index], style: TextStyles.bodyRegular),
                          if (currencyController.text == currencies[index])
                            Icon(CupertinoIcons.checkmark, color: ColorStyles.primary, size: 20.r),
                        ],
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

  Widget _buildItemsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CLIENT', style: TextStyles.caption1Regular.copyWith(color: ColorStyles.secondary, letterSpacing: 0.5)),
        SizedBox(height: 12.r),
        Container(
          decoration: BoxDecoration(color: ColorStyles.white, borderRadius: BorderRadius.circular(12.r)),
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
                        Text('Choose from list', style: TextStyles.bodyRegular.copyWith(color: ColorStyles.primary)),
                        SizedBox(width: 4.r),
                        Icon(CupertinoIcons.chevron_right, color: ColorStyles.primary, size: 18.r),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, indent: 16.r, color: ColorStyles.separator),
              _buildInlineField(label: 'Client Name', controller: clientNameController, placeholder: 'Enter name'),
              Divider(height: 1, indent: 16.r, color: ColorStyles.separator),
              _buildInlineField(label: 'Phone', controller: clientPhoneController, placeholder: 'Enter phone', keyboardType: TextInputType.phone),
            ],
          ),
        ),
        SizedBox(height: 24.r),
        Text('ITEM / SERVICE', style: TextStyles.caption1Regular.copyWith(color: ColorStyles.secondary, letterSpacing: 0.5)),
        SizedBox(height: 12.r),
        Container(
          decoration: BoxDecoration(color: ColorStyles.white, borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            children: [
              _buildInlineField(label: 'Description', controller: itemDescriptionController, placeholder: 'What are you billing'),
              Divider(height: 1, indent: 16.r, color: ColorStyles.separator),
              _buildInlineField(label: 'Price', controller: priceController, placeholder: '0.00', keyboardType: TextInputType.number, suffix: Text('£', style: TextStyles.bodyRegular)),
              Divider(height: 1, indent: 16.r, color: ColorStyles.separator),
              _buildInlineField(label: 'Quantity', controller: quantityController, placeholder: '1', keyboardType: TextInputType.number),
              Divider(height: 1, indent: 16.r, color: ColorStyles.separator),
              _buildInlineField(label: 'Tax', controller: taxController, placeholder: '0', keyboardType: TextInputType.number, suffix: Text('%', style: TextStyles.bodyRegular)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInlineField({required String label, required TextEditingController controller, required String placeholder, TextInputType keyboardType = TextInputType.text, Widget? suffix}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
      child: Row(
        children: [
          SizedBox(
            width: 100.r,
            child: Text(label, style: TextStyles.bodyRegular.copyWith(color: ColorStyles.primaryTxt)),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: controller,
                    style: TextStyles.bodyRegular.copyWith(color: ColorStyles.primaryTxt),
                    placeholder: placeholder,
                    placeholderStyle: TextStyles.bodyRegular.copyWith(color: ColorStyles.secondary.withValues(alpha: 0.5)),
                    padding: EdgeInsets.zero,
                    decoration: null,
                    keyboardType: keyboardType,
                  ),
                ),
                if (suffix != null) ...[SizedBox(width: 8.r), suffix],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('REVIEW', style: TextStyles.caption1Regular.copyWith(color: ColorStyles.secondary, letterSpacing: 0.5)),
        SizedBox(height: 16.r),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(color: ColorStyles.white, borderRadius: BorderRadius.circular(12.r)),
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
              _buildReviewRow('Price', '${getCurrencySymbol(currencyController.text)}${priceController.text}'),
              Divider(color: ColorStyles.separator),
              _buildReviewRow('Quantity', quantityController.text),
              Divider(color: ColorStyles.separator),
              _buildReviewRow('Tax', '${taxController.text}%'),
              Divider(color: ColorStyles.separator),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: TextStyles.bodyEmphasized),
                  Text('${getCurrencySymbol(currencyController.text)}${total.toStringAsFixed(2)}', style: TextStyles.title3Emphasized.copyWith(color: ColorStyles.primary)),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ProgressStep(step: 1, label: 'Details', isCompleted: currentStep > 0, isActive: currentStep == 0),
        Expanded(child: Container(margin: EdgeInsets.only(bottom: 16.h), height: 2.r, color: currentStep > 0 ? ColorStyles.primary : ColorStyles.separator)),
        _ProgressStep(step: 2, label: 'Items', isCompleted: currentStep > 1, isActive: currentStep == 1),
        Expanded(child: Container(margin: EdgeInsets.only(bottom: 16.h), height: 2.r, color: currentStep > 1 ? ColorStyles.primary : ColorStyles.separator)),
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

  const _ProgressStep({required this.step, required this.label, required this.isCompleted, required this.isActive});

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
            child: isCompleted
                ? Icon(CupertinoIcons.checkmark, color: ColorStyles.white, size: 16.r)
                : Text(step.toString(), style: TextStyles.footnoteEmphasized.copyWith(color: isActive ? ColorStyles.white : ColorStyles.secondary)),
          ),
        ),
        SizedBox(height: 4.r),
        Text(label, style: TextStyles.caption1Regular.copyWith(color: isActive ? ColorStyles.primary : ColorStyles.secondary)),
      ],
    );
  }
}

class _InputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? placeholder;

  const _InputWidget({required this.controller, this.label, this.placeholder});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: TextStyles.caption1Regular.copyWith(color: ColorStyles.secondary, letterSpacing: 0.5)),
          SizedBox(height: 8.r),
        ],
        Container(
          decoration: BoxDecoration(color: ColorStyles.white, borderRadius: BorderRadius.circular(10.r)),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: controller,
                  style: TextStyles.bodyRegular.copyWith(color: ColorStyles.primaryTxt),
                  placeholder: placeholder ?? label,
                  placeholderStyle: TextStyles.bodyRegular.copyWith(color: ColorStyles.secondary.withValues(alpha: 0.5)),
                  padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
                  decoration: null,
                ),
              ),
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

  const _SelectableContainer({required this.label, this.value, this.placeholder, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 8.r),
            child: Text(label, style: TextStyles.caption1Regular.copyWith(color: ColorStyles.secondary, letterSpacing: 0.5)),
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
            decoration: BoxDecoration(color: ColorStyles.white, borderRadius: BorderRadius.circular(12.r)),
            child: Row(
              children: [
                if (icon != null) ...[icon!, SizedBox(width: 12.r)],
                Expanded(
                  child: Text(
                    value ?? placeholder ?? 'Select',
                    style: TextStyles.bodyRegular.copyWith(
                      color: value != null ? ColorStyles.primaryTxt : ColorStyles.secondary.withValues(alpha: 0.8),
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
