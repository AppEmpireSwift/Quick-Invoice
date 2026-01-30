import 'dart:convert';
import 'dart:ui' as ui;

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

  Future<Uint8List?> _strokesToImage(List<List<Offset>> strokes) async {
    if (strokes.isEmpty) return null;
    const double scale = 3.0;
    const double width = 900;
    const double height = 450;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 2.0 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx * scale, stroke.first.dy * scale);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx * scale, stroke[i].dy * scale);
      }
      canvas.drawPath(path, paint);
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    return byteData.buffer.asUint8List();
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
          color: QuickInvoiceColorStyles.white,
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
                  initialDateTime: isInvoiceDate
                      ? invoiceDate ?? today
                      : dueDate ?? invoiceDate ?? today,
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

    // Save client if entered manually (not selected from list) - only for new invoices
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
              decoration: BoxDecoration(color: QuickInvoiceColorStyles.white),
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
          icon: Icon(CupertinoIcons.calendar, color: QuickInvoiceColorStyles.secondary, size: 20.r),
        ),
        SizedBox(height: 16.r),
        _SelectableContainer(
          label: 'Due date',
          value: dueDate != null ? _formatDate(dueDate) : null,
          placeholder: 'Select date',
          onTap: () => _showDatePicker(false),
          icon: Icon(CupertinoIcons.calendar, color: QuickInvoiceColorStyles.secondary, size: 20.r),
        ),
        SizedBox(height: 16.r),
        _SelectableContainer(
          label: 'Currency',
          value: currencyController.text.isEmpty ? null : currencyController.text,
          placeholder: 'Select currency',
          onTap: () => _showCurrencyPicker(),
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

  void _showCurrencyPicker() {
    final currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY', 'CNY', 'RUB'];
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 400.h,
        decoration: BoxDecoration(
          color: QuickInvoiceColorStyles.white,
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
                    Text('Select Currency', style: QuickInvoiceTextStyles.bodyEmphasized),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: QuickInvoiceColorStyles.secondary,
                      ),
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
                          Text(currencies[index], style: QuickInvoiceTextStyles.bodyRegular),
                          if (currencyController.text == currencies[index])
                            Icon(
                              CupertinoIcons.checkmark,
                              color: QuickInvoiceColorStyles.primary,
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
      ),
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
              Divider(height: 1, indent: 16.r, color: QuickInvoiceColorStyles.separator),
              _buildInlineField(
                label: 'Client Name',
                controller: clientNameController,
                placeholder: 'Enter name',
              ),
              Divider(height: 1, indent: 16.r, color: QuickInvoiceColorStyles.separator),
              _buildInlineField(
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
              _buildInlineField(
                label: 'Description',
                controller: itemDescriptionController,
                placeholder: 'What are you billing',
              ),
              Divider(height: 1, indent: 16.r, color: QuickInvoiceColorStyles.separator),
              _buildInlineField(
                label: 'Price',
                controller: priceController,
                placeholder: '0.00',
                keyboardType: TextInputType.number,
                suffix: Text(
                  getCurrencySymbol(currencyController.text),
                  style: QuickInvoiceTextStyles.bodyRegular,
                ),
              ),
              Divider(height: 1, indent: 16.r, color: QuickInvoiceColorStyles.separator),
              _buildInlineField(
                label: 'Quantity',
                controller: quantityController,
                placeholder: '1',
                keyboardType: TextInputType.number,
              ),
              Divider(height: 1, indent: 16.r, color: QuickInvoiceColorStyles.separator),
              _buildInlineField(
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

  Widget _buildInlineField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
      child: Row(
        children: [
          SizedBox(
            width: 115.r,
            child: Text(
              label,
              style: QuickInvoiceTextStyles.calloutRegular.copyWith(
                color: QuickInvoiceColorStyles.primaryTxt,
              ),
            ),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: controller,
                    style: QuickInvoiceTextStyles.bodyRegular.copyWith(
                      color: QuickInvoiceColorStyles.primaryTxt,
                    ),
                    placeholder: placeholder,
                    placeholderStyle: QuickInvoiceTextStyles.bodyRegular.copyWith(
                      color: QuickInvoiceColorStyles.secondary.withValues(alpha: 0.5),
                    ),
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
              _buildReviewRow('Invoice Number', invoiceNumberController.text),
              Divider(color: QuickInvoiceColorStyles.separator),
              _buildReviewRow('Invoice Date', _formatDate(invoiceDate)),
              Divider(color: QuickInvoiceColorStyles.separator),
              _buildReviewRow('Due Date', _formatDate(dueDate)),
              Divider(color: QuickInvoiceColorStyles.separator),
              _buildReviewRow('Client', clientNameController.text),
              Divider(color: QuickInvoiceColorStyles.separator),
              _buildReviewRow('Description', itemDescriptionController.text),
              Divider(color: QuickInvoiceColorStyles.separator),
              _buildReviewRow(
                'Price',
                '${getCurrencySymbol(currencyController.text)}${priceController.text}',
              ),
              Divider(color: QuickInvoiceColorStyles.separator),
              _buildReviewRow('Quantity', quantityController.text),
              Divider(color: QuickInvoiceColorStyles.separator),
              _buildReviewRow('Tax', '${taxController.text}%'),
              Divider(color: QuickInvoiceColorStyles.separator),
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
          padding: EdgeInsets.zero,
          onPressed: _showSignatureDialog,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 100.r),
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
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.memory(_signatureImage!),
                  ),
          ),
        ),
      ],
    );
  }

  void _showSignatureDialog() {
    List<List<Offset>> tempStrokes = [];
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 24.r),
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: QuickInvoiceColorStyles.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Signature', style: QuickInvoiceTextStyles.title3Emphasized),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setDialogState(() => tempStrokes = []);
                          },
                          child: Text(
                            'Clear',
                            style: QuickInvoiceTextStyles.footnoteRegular.copyWith(
                              color: QuickInvoiceColorStyles.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.r),
                    Container(
                      height: 200.r,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: QuickInvoiceColorStyles.bgSecondary,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: QuickInvoiceColorStyles.separator),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: GestureDetector(
                          onPanStart: (details) {
                            setDialogState(() {
                              tempStrokes.add([details.localPosition]);
                            });
                          },
                          onPanUpdate: (details) {
                            setDialogState(() {
                              tempStrokes.last.add(details.localPosition);
                            });
                          },
                          child: CustomPaint(
                            painter: _SignaturePainter(tempStrokes),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.r),
                    Text(
                      'Draw your signature above',
                      style: QuickInvoiceTextStyles.caption1Regular.copyWith(
                        color: QuickInvoiceColorStyles.secondary,
                      ),
                    ),
                    SizedBox(height: 20.r),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.pop(ctx),
                            child: Container(
                              height: 44.r,
                              decoration: BoxDecoration(
                                border: Border.all(color: QuickInvoiceColorStyles.separator),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                child: Text('Cancel', style: QuickInvoiceTextStyles.bodyRegular),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.r),
                        Expanded(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              final image = await _strokesToImage(tempStrokes);
                              setState(() => _signatureImage = image);
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                            child: Container(
                              height: 44.r,
                              decoration: BoxDecoration(
                                color: QuickInvoiceColorStyles.primary,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                child: Text(
                                  'Done',
                                  style: QuickInvoiceTextStyles.bodyEmphasized.copyWith(
                                    color: QuickInvoiceColorStyles.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: QuickInvoiceTextStyles.footnoteRegular.copyWith(
              color: QuickInvoiceColorStyles.secondary,
            ),
          ),
          Expanded(
            child: Text(value, style: QuickInvoiceTextStyles.bodyRegular, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
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
        _ProgressStep(
          step: 1,
          label: 'Details',
          isCompleted: currentStep > 0,
          isActive: currentStep == 0,
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            height: 2.r,
            color: currentStep > 0
                ? QuickInvoiceColorStyles.primary
                : QuickInvoiceColorStyles.separator,
          ),
        ),
        _ProgressStep(
          step: 2,
          label: 'Items',
          isCompleted: currentStep > 1,
          isActive: currentStep == 1,
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            height: 2.r,
            color: currentStep > 1
                ? QuickInvoiceColorStyles.primary
                : QuickInvoiceColorStyles.separator,
          ),
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
            color: isCompleted || isActive
                ? QuickInvoiceColorStyles.primary
                : QuickInvoiceColorStyles.separator,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(CupertinoIcons.checkmark, color: QuickInvoiceColorStyles.white, size: 16.r)
                : Text(
                    step.toString(),
                    style: QuickInvoiceTextStyles.footnoteEmphasized.copyWith(
                      color: isActive
                          ? QuickInvoiceColorStyles.white
                          : QuickInvoiceColorStyles.secondary,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 4.r),
        Text(
          label,
          style: QuickInvoiceTextStyles.caption1Regular.copyWith(
            color: isActive ? QuickInvoiceColorStyles.primary : QuickInvoiceColorStyles.secondary,
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

  const _InputWidget({required this.controller, this.label, this.placeholder});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: QuickInvoiceTextStyles.caption1Regular.copyWith(
              color: QuickInvoiceColorStyles.secondary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8.r),
        ],
        Container(
          decoration: BoxDecoration(
            color: QuickInvoiceColorStyles.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: controller,
                  style: QuickInvoiceTextStyles.bodyRegular.copyWith(
                    color: QuickInvoiceColorStyles.primaryTxt,
                  ),
                  placeholder: placeholder ?? label,
                  placeholderStyle: QuickInvoiceTextStyles.bodyRegular.copyWith(
                    color: QuickInvoiceColorStyles.secondary.withValues(alpha: 0.5),
                  ),
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
              style: QuickInvoiceTextStyles.caption1Regular.copyWith(
                color: QuickInvoiceColorStyles.secondary,
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
              color: QuickInvoiceColorStyles.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                if (icon != null) ...[icon!, SizedBox(width: 12.r)],
                Expanded(
                  child: Text(
                    value ?? placeholder ?? 'Select',
                    style: QuickInvoiceTextStyles.bodyRegular.copyWith(
                      color: value != null
                          ? QuickInvoiceColorStyles.primaryTxt
                          : QuickInvoiceColorStyles.secondary.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_down,
                  color: QuickInvoiceColorStyles.secondary,
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
