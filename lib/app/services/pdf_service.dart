import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';

enum PdfTemplate { classic, modern, minimal }

class PdfService {
  static Future<Uint8List> generateInvoice(Invoice invoice, {PdfTemplate template = PdfTemplate.classic}) async {
    switch (template) {
      case PdfTemplate.classic:
        return _generateClassic(invoice);
      case PdfTemplate.modern:
        return _generateModern(invoice);
      case PdfTemplate.minimal:
        return _generateMinimal(invoice);
    }
  }

  static Future<void> printInvoice(Invoice invoice, {PdfTemplate template = PdfTemplate.classic}) async {
    final pdf = await generateInvoice(invoice, template: template);
    await Printing.layoutPdf(onLayout: (_) => pdf);
  }

  static Future<void> shareInvoice(Invoice invoice, {PdfTemplate template = PdfTemplate.classic}) async {
    final pdf = await generateInvoice(invoice, template: template);
    await Printing.sharePdf(bytes: pdf, filename: 'invoice_${invoice.invoiceNumber}.pdf');
  }

  static String _formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  static String _formatCurrency(double amount, String currency) => '$currency ${amount.toStringAsFixed(2)}';

  static Future<Uint8List> _generateClassic(Invoice invoice) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('INVOICE', style: pw.TextStyle(font: fontBold, fontSize: 32, color: PdfColors.blue800)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('#${invoice.invoiceNumber}', style: pw.TextStyle(font: fontBold, fontSize: 16)),
                      pw.SizedBox(height: 4),
                      pw.Text('Date: ${_formatDate(invoice.invoiceDate)}', style: pw.TextStyle(font: font, fontSize: 10)),
                      pw.Text('Due: ${_formatDate(invoice.dueDate)}', style: pw.TextStyle(font: font, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Bill To:', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    pw.SizedBox(height: 8),
                    pw.Text(invoice.clientName, style: pw.TextStyle(font: font, fontSize: 14)),
                    if (invoice.clientPhoneNumber.isNotEmpty)
                      pw.Text(invoice.clientPhoneNumber, style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue800),
                    children: [
                      _tableCell('Item', fontBold, isHeader: true),
                      _tableCell('Qty', fontBold, isHeader: true),
                      _tableCell('Price', fontBold, isHeader: true),
                      _tableCell('Total', fontBold, isHeader: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell(invoice.itemName, font),
                      _tableCell(invoice.itemQuantity.toString(), font),
                      _tableCell(_formatCurrency(invoice.itemPrice, invoice.currency), font),
                      _tableCell(_formatCurrency(invoice.itemPrice * invoice.itemQuantity, invoice.currency), font),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 200,
                  child: pw.Column(
                    children: [
                      _summaryRow('Subtotal', _formatCurrency(invoice.itemPrice * invoice.itemQuantity, invoice.currency), font),
                      if (invoice.tax > 0)
                        _summaryRow('Tax (${invoice.tax}%)', _formatCurrency(invoice.totalAmount - (invoice.itemPrice * invoice.itemQuantity), invoice.currency), font),
                      pw.Divider(),
                      _summaryRow('Total', _formatCurrency(invoice.totalAmount, invoice.currency), fontBold),
                    ],
                  ),
                ),
              ),
              if (invoice.note.isNotEmpty) ...[
                pw.SizedBox(height: 40),
                pw.Text('Notes:', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                pw.SizedBox(height: 8),
                pw.Text(invoice.note, style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
              ],
              pw.Spacer(),
              pw.Center(
                child: pw.Text('Thank you for your business!', style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey600)),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> _generateModern(Invoice invoice) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(24),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.indigo,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('INVOICE', style: pw.TextStyle(font: fontBold, fontSize: 28, color: PdfColors.white)),
                        pw.Text('#${invoice.invoiceNumber}', style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.white)),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        invoice.status.toUpperCase(),
                        style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.indigo),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('BILL TO', style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.grey600)),
                        pw.SizedBox(height: 8),
                        pw.Text(invoice.clientName, style: pw.TextStyle(font: fontBold, fontSize: 16)),
                        if (invoice.clientPhoneNumber.isNotEmpty)
                          pw.Text(invoice.clientPhoneNumber, style: pw.TextStyle(font: font, fontSize: 11)),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice Date', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600)),
                      pw.Text(_formatDate(invoice.invoiceDate), style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      pw.SizedBox(height: 12),
                      pw.Text('Due Date', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600)),
                      pw.Text(_formatDate(invoice.dueDate), style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey200),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(8)),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(flex: 3, child: pw.Text('Description', style: pw.TextStyle(font: fontBold, fontSize: 11))),
                          pw.Expanded(child: pw.Text('Qty', style: pw.TextStyle(font: fontBold, fontSize: 11), textAlign: pw.TextAlign.center)),
                          pw.Expanded(child: pw.Text('Rate', style: pw.TextStyle(font: fontBold, fontSize: 11), textAlign: pw.TextAlign.right)),
                          pw.Expanded(child: pw.Text('Amount', style: pw.TextStyle(font: fontBold, fontSize: 11), textAlign: pw.TextAlign.right)),
                        ],
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Row(
                        children: [
                          pw.Expanded(flex: 3, child: pw.Text(invoice.itemName, style: pw.TextStyle(font: font, fontSize: 11))),
                          pw.Expanded(child: pw.Text(invoice.itemQuantity.toString(), style: pw.TextStyle(font: font, fontSize: 11), textAlign: pw.TextAlign.center)),
                          pw.Expanded(child: pw.Text(_formatCurrency(invoice.itemPrice, invoice.currency), style: pw.TextStyle(font: font, fontSize: 11), textAlign: pw.TextAlign.right)),
                          pw.Expanded(child: pw.Text(_formatCurrency(invoice.itemPrice * invoice.itemQuantity, invoice.currency), style: pw.TextStyle(font: font, fontSize: 11), textAlign: pw.TextAlign.right)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey50,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        _summaryRow('Subtotal', _formatCurrency(invoice.itemPrice * invoice.itemQuantity, invoice.currency), font),
                        if (invoice.tax > 0)
                          _summaryRow('Tax (${invoice.tax}%)', _formatCurrency(invoice.totalAmount - (invoice.itemPrice * invoice.itemQuantity), invoice.currency), font),
                        pw.SizedBox(height: 8),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.indigo,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total', style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.white)),
                              pw.Text(_formatCurrency(invoice.totalAmount, invoice.currency), style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (invoice.note.isNotEmpty) ...[
                pw.SizedBox(height: 30),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Notes', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                      pw.SizedBox(height: 4),
                      pw.Text(invoice.note, style: pw.TextStyle(font: font, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> _generateMinimal(Invoice invoice) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Invoice', style: pw.TextStyle(font: fontBold, fontSize: 36)),
              pw.SizedBox(height: 8),
              pw.Text('#${invoice.invoiceNumber}', style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey600)),
              pw.SizedBox(height: 48),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('To', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey500)),
                        pw.SizedBox(height: 4),
                        pw.Text(invoice.clientName, style: pw.TextStyle(font: fontBold, fontSize: 14)),
                        if (invoice.clientPhoneNumber.isNotEmpty)
                          pw.Text(invoice.clientPhoneNumber, style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey600)),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: ${_formatDate(invoice.invoiceDate)}', style: pw.TextStyle(font: font, fontSize: 11)),
                      pw.Text('Due: ${_formatDate(invoice.dueDate)}', style: pw.TextStyle(font: font, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 48),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 12),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 4, child: pw.Text('Item', style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.grey600))),
                    pw.Expanded(child: pw.Text('Qty', style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.grey600), textAlign: pw.TextAlign.center)),
                    pw.Expanded(child: pw.Text('Price', style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.grey600), textAlign: pw.TextAlign.right)),
                    pw.Expanded(child: pw.Text('Total', style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.grey600), textAlign: pw.TextAlign.right)),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 16),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 4, child: pw.Text(invoice.itemName, style: pw.TextStyle(font: font, fontSize: 12))),
                    pw.Expanded(child: pw.Text(invoice.itemQuantity.toString(), style: pw.TextStyle(font: font, fontSize: 12), textAlign: pw.TextAlign.center)),
                    pw.Expanded(child: pw.Text(_formatCurrency(invoice.itemPrice, invoice.currency), style: pw.TextStyle(font: font, fontSize: 12), textAlign: pw.TextAlign.right)),
                    pw.Expanded(child: pw.Text(_formatCurrency(invoice.itemPrice * invoice.itemQuantity, invoice.currency), style: pw.TextStyle(font: font, fontSize: 12), textAlign: pw.TextAlign.right)),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: 180,
                    child: pw.Column(
                      children: [
                        _summaryRow('Subtotal', _formatCurrency(invoice.itemPrice * invoice.itemQuantity, invoice.currency), font),
                        if (invoice.tax > 0)
                          _summaryRow('Tax', _formatCurrency(invoice.totalAmount - (invoice.itemPrice * invoice.itemQuantity), invoice.currency), font),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total', style: pw.TextStyle(font: fontBold, fontSize: 16)),
                            pw.Text(_formatCurrency(invoice.totalAmount, invoice.currency), style: pw.TextStyle(font: fontBold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (invoice.note.isNotEmpty) ...[
                pw.SizedBox(height: 48),
                pw.Text('Notes', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey500)),
                pw.SizedBox(height: 4),
                pw.Text(invoice.note, style: pw.TextStyle(font: font, fontSize: 11)),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _tableCell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 11,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _summaryRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 11)),
        ],
      ),
    );
  }
}
