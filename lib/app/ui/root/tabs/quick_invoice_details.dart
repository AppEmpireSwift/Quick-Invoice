import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../data/database.dart';
import '../../../../style/quick_invoice_style.dart';
import '../../../app.dart';
import '../../../services/app_exporting_service.dart';
import '../../../services/invoice_2_pdf_service.dart';
import '../../../services/premium_limits.dart';
import '../../premium/quick_invoice_main_paywall.page.dart';
import 'quick_invoice_create_invoice.dart';
import 'quick_invoice_home.dart';
import 'quick_invoice_pdf_preview.dart';

class QuickInvoiceInvoiceDetailsPage extends StatefulWidget {
  final Invoice invoice;
  final VoidCallback onUpdate;

  const QuickInvoiceInvoiceDetailsPage({super.key, required this.invoice, required this.onUpdate});

  @override
  State<QuickInvoiceInvoiceDetailsPage> createState() => _QuickInvoiceInvoiceDetailsPageState();
}

class _QuickInvoiceInvoiceDetailsPageState extends State<QuickInvoiceInvoiceDetailsPage> {
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
        return QuickInvoiceColorStyles.green;
      case 'pending':
        return QuickInvoiceColorStyles.orange;
      case 'overdue':
        return QuickInvoiceColorStyles.pink;
      default:
        return QuickInvoiceColorStyles.secondary;
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
      backgroundColor: QuickInvoiceColorStyles.bgSecondary,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Container(
              color: QuickInvoiceColorStyles.white.withValues(alpha: 0.9),
              padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 8.r),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.chevron_back, color: QuickInvoiceColorStyles.primary),
                          Text(
                            'Back',
                            style: QuickInvoiceTextStyles.bodyRegular.copyWith(color: QuickInvoiceColorStyles.primary),
                          ),
                        ],
                      ),
                    ),
                    Text('Invoice', style: QuickInvoiceTextStyles.bodyEmphasized),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showExportOptions(),
                      child: Icon(CupertinoIcons.ellipsis, color: QuickInvoiceColorStyles.primary, size: 22.r),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: QuickInvoiceColorStyles.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.invoiceNumber,
                            style: QuickInvoiceTextStyles.footnoteRegular.copyWith(
                              color: QuickInvoiceColorStyles.white.withValues(alpha: 0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8.r),
                          Text(
                            '${getCurrencySymbol(invoice.currency)}${invoice.totalAmount.toStringAsFixed(2)}',
                            style: QuickInvoiceTextStyles.largeTitleEmphasized.copyWith(
                              color: QuickInvoiceColorStyles.white,
                              fontSize: 32.sp.clamp(0, 38),
                            ),
                          ),
                          SizedBox(height: 8.r),
                          Text(
                            'Due ${_formatDate(invoice.dueDate)}',
                            style: QuickInvoiceTextStyles.footnoteRegular.copyWith(
                              color: QuickInvoiceColorStyles.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.r),
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: QuickInvoiceColorStyles.white,
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
                              color: QuickInvoiceColorStyles.white,
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
                                  style: QuickInvoiceTextStyles.footnoteRegular.copyWith(
                                    color: QuickInvoiceColorStyles.secondary,
                                  ),
                                ),
                                SizedBox(height: 2.r),
                                Text(
                                  invoice.status.substring(0, 1).toUpperCase() +
                                      invoice.status.substring(1),
                                  style: QuickInvoiceTextStyles.bodyEmphasized.copyWith(
                                    color: _getStatusColor(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: invoice.status == 'paid',
                            onChanged: (value) => _updateStatus(value ? 'paid' : 'pending'),
                            activeTrackColor: QuickInvoiceColorStyles.green,
                          ),
                        ],
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
                        children: [
                          _buildDetailRow('Client', invoice.clientName),
                          Divider(color: QuickInvoiceColorStyles.separator, height: 24.r),
                          _buildDetailRow('Invoice Date', _formatDate(invoice.invoiceDate)),
                          Divider(color: QuickInvoiceColorStyles.separator, height: 24.r),
                          _buildDetailRow('Due Date', _formatDate(invoice.dueDate)),
                          Divider(color: QuickInvoiceColorStyles.separator, height: 24.r),
                          _buildDetailRow('Currency', invoice.currency),
                        ],
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
                          Text('Items', style: QuickInvoiceTextStyles.bodyEmphasized),
                          SizedBox(height: 16.r),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(invoice.itemName, style: QuickInvoiceTextStyles.bodyRegular),
                                    SizedBox(height: 4.r),
                                    Text(
                                      '${invoice.itemQuantity} x ${getCurrencySymbol(invoice.currency)}${invoice.itemPrice.toStringAsFixed(2)}',
                                      style: QuickInvoiceTextStyles.footnoteRegular.copyWith(
                                        color: QuickInvoiceColorStyles.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${getCurrencySymbol(invoice.currency)}${(invoice.itemPrice * invoice.itemQuantity).toStringAsFixed(2)}',
                                style: QuickInvoiceTextStyles.bodyEmphasized,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (invoice.signature.isNotEmpty) ...[
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
                            Text('Signature', style: QuickInvoiceTextStyles.bodyEmphasized),
                            SizedBox(height: 12.r),
                            Container(
                              width: double.infinity,
                              height: 80.r,
                              decoration: BoxDecoration(
                                border: Border.all(color: QuickInvoiceColorStyles.separator),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Image.memory(
                                base64Decode(invoice.signature),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 24.r),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(color: QuickInvoiceColorStyles.white),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _showTemplateSelector((template) {
                            Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                builder:
                                    (_) => QuickInvoicePdfPreviewPage(
                                      invoice: invoice,
                                      template: template,
                                    ),
                              ),
                            );
                          });
                        },
                        child: Container(
                          height: 50.r,
                          decoration: BoxDecoration(
                            border: Border.all(color: QuickInvoiceColorStyles.primary),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              'Preview',
                              style: QuickInvoiceTextStyles.bodyEmphasized.copyWith(color: QuickInvoiceColorStyles.primary),
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
                          if (!PremiumLimits.canExport()) {
                            QuickInvoiceMainPaywallPage.show(context);
                            return;
                          }
                          _showTemplateSelector((template) {
                            Invoice2PdfService.shareInvoice(invoice, template: template);
                          });
                        },
                        child: Container(
                          height: 50.r,
                          decoration: BoxDecoration(
                            color: QuickInvoiceColorStyles.primary,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              'Send',
                              style: QuickInvoiceTextStyles.bodyEmphasized.copyWith(color: QuickInvoiceColorStyles.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
        Text(label, style: QuickInvoiceTextStyles.bodyRegular.copyWith(color: QuickInvoiceColorStyles.secondary)),
        Expanded(
          child: Text(
            value,
            style: QuickInvoiceTextStyles.bodyRegular,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showExportOptions() {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: !quickInvoiceUIHelper.shouldDisableBarrierDismiss,
      builder:
          (context) => CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _editInvoice();
                },
                child: Text('Edit'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  AppExportingService.shareCsv([invoice]);
                },
                child: Text('Export CSV'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  AppExportingService.shareExcel([invoice]);
                },
                child: Text('Export Excel'),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  _confirmDelete();
                },
                child: Text('Delete'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ),
    );
  }

  void _editInvoice() async {
    final result = await Navigator.of(context, rootNavigator: true).push<bool>(
      CupertinoPageRoute(builder: (_) => QuickInvoiceCreateInvoicePage(editInvoice: invoice)),
    );
    if (result == true) {
      final refreshed = await AppDatabase.instance.getInvoiceById(invoice.id);
      if (refreshed != null && mounted) {
        setState(() => invoice = refreshed);
        widget.onUpdate();
      }
    }
  }

  void _confirmDelete() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: !quickInvoiceUIHelper.shouldDisableBarrierDismiss,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text('Delete Invoice'),
            content: Text('Are you sure you want to delete this invoice?'),
            actions: [
              CupertinoDialogAction(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () async {
                  Navigator.pop(context);
                  await AppDatabase.instance.deleteInvoice(invoice.id);
                  widget.onUpdate();
                  if (mounted) Navigator.pop(this.context);
                },
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showTemplateSelector(Function(PdfTemplate) onTemplateSelected) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: !quickInvoiceUIHelper.shouldDisableBarrierDismiss,
      builder:
          (context) => TemplateSelectorModal(
            onTemplateSelected: (template) {
              Navigator.pop(context);
              onTemplateSelected(template);
            },
          ),
    );
  }
}
