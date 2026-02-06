import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../data/database.dart';
import '../../../../style/quick_invoice_style.dart';
import '../../../services/premium_limits.dart';
import '../../premium/quick_invoice_main_paywall.page.dart';
import 'quick_invoice_create_invoice_widgets.dart';
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
  Uint8List? _signatureImage;

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
      if (edit.signature.isNotEmpty) {
        try {
          _signatureImage = base64Decode(edit.signature);
        } catch (_) {}
      }
    } else {
      invoiceDate = DateTime.now();
      dueDate = DateTime.now().add(Duration(days: 30));
    }
    priceController.addListener(() => setState(() {}));
    quantityController.addListener(() => setState(() {}));
    taxController.addListener(() => setState(() {}));
    invoiceNumberController.addListener(() => setState(() {}));
    currencyController.addListener(() => setState(() {}));
    clientNameController.addListener(() => setState(() {}));
    itemDescriptionController.addListener(() => setState(() {}));
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

  Future<String> _encodeSignature() async {
    if (_signatureImage == null) return '';
    return base64Encode(_signatureImage!);
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

  void _showDatePicker(bool isInvoiceDate) {
    showInvoiceDatePicker(
      context: context,
      isInvoiceDate: isInvoiceDate,
      invoiceDate: invoiceDate,
      dueDate: dueDate,
      onDateSelected: (newDate, isInvoice) {
        setState(() {
          if (isInvoice) {
            invoiceDate = newDate;
            if (dueDate != null && dueDate!.isBefore(newDate)) dueDate = newDate;
          } else {
            dueDate = newDate;
          }
        });
      },
    );
  }

  bool get isCurrentStepValid {
    switch (_currentStep) {
      case 0:
        return invoiceNumberController.text.isNotEmpty &&
            invoiceDate != null &&
            dueDate != null &&
            currencyController.text.isNotEmpty;
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
    final signatureData = await _encodeSignature();

    if (widget.editInvoice == null &&
        selectedClient == null &&
        clientNameController.text.isNotEmpty) {
      final clientId = DateTime.now().millisecondsSinceEpoch.toString();
      final newClient = ClientsCompanion(
        id: Value(clientId),
        name: Value(clientNameController.text),
        phoneNumber: Value(clientPhoneController.text),
      );
      await AppDatabase.instance.insertClient(newClient);
    }

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
        signature: Value(signatureData),
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
        signature: Value(signatureData),
      );
      await AppDatabase.instance.insertInvoice(invoice);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: QuickInvoiceColorStyles.bgSecondary,
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: QuickInvoiceTextStyles.bodyRegular.copyWith(
              color: QuickInvoiceColorStyles.primary,
            ),
          ),
        ),
        middle: Text(widget.editInvoice != null ? 'Edit Invoice' : 'New Invoice'),
        backgroundColor: QuickInvoiceColorStyles.white,
        automaticBackgroundVisibility: false,
        transitionBetweenRoutes: false,
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: CreateInvoiceProgressIndicator(currentStep: _currentStep),
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
              decoration: BoxDecoration(color: QuickInvoiceColorStyles.white),
              child: SafeArea(
                top: false,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (!isCurrentStepValid) return;
                    HapticFeedback.selectionClick();
                    if (_currentStep < 2) {
                      setState(() => _currentStep++);
                    } else {
                      _handleSave();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50.r,
                    decoration: BoxDecoration(
                      color: isCurrentStepValid
                          ? QuickInvoiceColorStyles.primary
                          : QuickInvoiceColorStyles.fillsTertiary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _currentStep < 2 ? 'Continue' : 'Save',
                      style: QuickInvoiceTextStyles.bodyEmphasized.copyWith(
                        color: isCurrentStepValid
                            ? QuickInvoiceColorStyles.white
                            : QuickInvoiceColorStyles.secondary,
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
        CreateInvoiceInputWidget(
          controller: invoiceNumberController,
          label: 'Invoice number',
          placeholder: 'INV-001',
        ),
        SizedBox(height: 16.r),
        CreateInvoiceSelectableContainer(
          label: 'Invoice date',
          value: invoiceDate != null ? _formatDate(invoiceDate) : null,
          placeholder: 'Select date',
          onTap: () => _showDatePicker(true),
          icon: Icon(CupertinoIcons.calendar, color: QuickInvoiceColorStyles.secondary, size: 20.r),
        ),
        SizedBox(height: 16.r),
        CreateInvoiceSelectableContainer(
          label: 'Due date',
          value: dueDate != null ? _formatDate(dueDate) : null,
          placeholder: 'Select date',
          onTap: () => _showDatePicker(false),
          icon: Icon(CupertinoIcons.calendar, color: QuickInvoiceColorStyles.secondary, size: 20.r),
        ),
        SizedBox(height: 16.r),
        CreateInvoiceSelectableContainer(
          label: 'Currency',
          value: currencyController.text.isEmpty ? null : currencyController.text,
          placeholder: 'Select currency',
          onTap: () => showCurrencyPicker(
            context: context,
            currentCurrency: currencyController.text,
            onCurrencySelected: (currency) {
              setState(() => currencyController.text = currency);
            },
          ),
          icon: currencyController.text.isEmpty
              ? null
              : Text(
                  getCurrencySymbol(currencyController.text),
                  style: QuickInvoiceTextStyles.bodyEmphasized.copyWith(
                    color: QuickInvoiceColorStyles.secondary,
                    fontSize: 20.sp.clamp(0, 26),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildItemsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CLIENT',
          style: QuickInvoiceTextStyles.caption1Regular.copyWith(
            color: QuickInvoiceColorStyles.secondary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.r),
        Container(
          decoration: BoxDecoration(
            color: QuickInvoiceColorStyles.white,
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
                    Text('Select Client', style: QuickInvoiceTextStyles.bodyRegular),
                    Row(
                      children: [
                        Text(
                          'Choose from list',
                          style: QuickInvoiceTextStyles.bodyRegular.copyWith(
                            color: QuickInvoiceColorStyles.primary,
                          ),
                        ),
                        SizedBox(width: 4.r),
                        Icon(
                          CupertinoIcons.chevron_right,
                          color: QuickInvoiceColorStyles.primary,
                          size: 18.r,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, indent: 16.r, color: QuickInvoiceColorStyles.separatorLight),
              CreateInvoiceInlineField(
                label: 'Client Name',
                controller: clientNameController,
                placeholder: 'Enter name',
              ),
              Divider(height: 1, indent: 16.r, color: QuickInvoiceColorStyles.separatorLight),
              CreateInvoiceInlineField(
                label: 'Phone',
                controller: clientPhoneController,
                placeholder: 'Enter phone',
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        SizedBox(height: 24.r),
        Text(
          'ITEM / SERVICE',
          style: QuickInvoiceTextStyles.caption1Regular.copyWith(
            color: QuickInvoiceColorStyles.secondary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.r),
        Container(
          decoration: BoxDecoration(
            color: QuickInvoiceColorStyles.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              CreateInvoiceInlineField(
                label: 'Description',
                controller: itemDescriptionController,
                placeholder: 'What are you billing',
              ),
              Divider(height: 1, indent: 16.r, color: QuickInvoiceColorStyles.separatorLight),
              CreateInvoiceInlineField(
                label: 'Price',
                controller: priceController,
                placeholder: '0.00',
                keyboardType: TextInputType.number,
                suffix: Text(
                  getCurrencySymbol(currencyController.text),
                  style: QuickInvoiceTextStyles.bodyRegular,
                ),
              ),
              Divider(height: 1, indent: 16.r, color: QuickInvoiceColorStyles.separatorLight),
              CreateInvoiceInlineField(
                label: 'Quantity',
                controller: quantityController,
                placeholder: '1',
                keyboardType: TextInputType.number,
              ),
              Divider(height: 1, indent: 16.r, color: QuickInvoiceColorStyles.separatorLight),
              CreateInvoiceInlineField(
                label: 'Tax',
                controller: taxController,
                placeholder: '0',
                keyboardType: TextInputType.number,
                suffix: Text('%', style: QuickInvoiceTextStyles.bodyRegular),
              ),
            ],
          ),
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
          style: QuickInvoiceTextStyles.caption1Regular.copyWith(
            color: QuickInvoiceColorStyles.secondary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 16.r),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: QuickInvoiceColorStyles.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CreateInvoiceReviewRow(label: 'Invoice Number', value: invoiceNumberController.text),
              Divider(color: QuickInvoiceColorStyles.separatorLight),
              CreateInvoiceReviewRow(label: 'Invoice Date', value: _formatDate(invoiceDate)),
              Divider(color: QuickInvoiceColorStyles.separatorLight),
              CreateInvoiceReviewRow(label: 'Due Date', value: _formatDate(dueDate)),
              Divider(color: QuickInvoiceColorStyles.separatorLight),
              CreateInvoiceReviewRow(label: 'Client', value: clientNameController.text),
              Divider(color: QuickInvoiceColorStyles.separatorLight),
              CreateInvoiceReviewRow(label: 'Description', value: itemDescriptionController.text),
              Divider(color: QuickInvoiceColorStyles.separatorLight),
              CreateInvoiceReviewRow(
                label: 'Price',
                value: '${getCurrencySymbol(currencyController.text)}${priceController.text}',
              ),
              Divider(color: QuickInvoiceColorStyles.separatorLight),
              CreateInvoiceReviewRow(label: 'Quantity', value: quantityController.text),
              Divider(color: QuickInvoiceColorStyles.separatorLight),
              CreateInvoiceReviewRow(label: 'Tax', value: '${taxController.text}%'),
              Divider(color: QuickInvoiceColorStyles.separatorLight),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text('Total', style: QuickInvoiceTextStyles.bodyEmphasized)),
                  Flexible(
                    flex: 5,
                    child: Text(
                      '${getCurrencySymbol(currencyController.text)}${total.toStringAsFixed(2)}',
                      style: QuickInvoiceTextStyles.title3Emphasized.copyWith(
                        color: QuickInvoiceColorStyles.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24.r),
        Text(
          'SIGNATURE',
          style: QuickInvoiceTextStyles.caption1Regular.copyWith(
            color: QuickInvoiceColorStyles.secondary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.r),
        CupertinoButton(
          sizeStyle: CupertinoButtonSize.small,
          padding: EdgeInsets.zero,
          onPressed: () {
            if (PremiumLimits.isPremium) {
              showSignatureDialog(
                context: context,
                onStrokesToImage: strokesToImage,
                onSignatureSaved: (image) => setState(() => _signatureImage = image),
              );
            } else {
              QuickInvoiceMainPaywallPage.show(context);
            }
          },
          child: Center(
            child: SizedBox(
              height: 200.h,
              width: 200.h,
              child: Container(
                decoration: BoxDecoration(
                  color: QuickInvoiceColorStyles.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _signatureImage == null
                        ? QuickInvoiceColorStyles.separator
                        : QuickInvoiceColorStyles.primary,
                  ),
                ),
                child: _signatureImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.signature,
                            size: 28.r,
                            color: QuickInvoiceColorStyles.secondary,
                          ),
                          SizedBox(height: 8.r),
                          Text(
                            'Tap to add signature',
                            style: QuickInvoiceTextStyles.footnoteRegular.copyWith(
                              color: QuickInvoiceColorStyles.secondary,
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.memory(
                            _signatureImage!,
                            height: 200.h,
                            width: 200.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
