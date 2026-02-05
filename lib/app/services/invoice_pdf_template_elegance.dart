part of 'invoice_2_pdf_service.dart';

extension _EleganceTemplate on Invoice2PdfService {
  static Future<Uint8List> generateElegance(
    Invoice invoice,
    pw.Font font,
    pw.Font fontBold,
  ) async {
    final pdf = pw.Document();
    final company = await Invoice2PdfService._getCompanyInfo();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (company['name']!.isNotEmpty)
                        pw.Text(
                          company['name']!,
                          style: pw.TextStyle(font: fontBold, fontSize: 24),
                        ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Invoice',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 14,
                          color: PdfColors.grey600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        '#${invoice.invoiceNumber}',
                        style: pw.TextStyle(font: fontBold, fontSize: 18),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        Invoice2PdfService._formatDate(invoice.invoiceDate),
                        style: pw.TextStyle(font: font, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                height: 1,
                color: PdfColors.grey300,
              ),
              pw.SizedBox(height: 40),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Bill To',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                            color: PdfColors.grey500,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          invoice.clientName,
                          style: pw.TextStyle(font: fontBold, fontSize: 14),
                        ),
                        if (invoice.clientPhoneNumber.isNotEmpty)
                          pw.Text(
                            invoice.clientPhoneNumber,
                            style: pw.TextStyle(font: font, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Due Date',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey500,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        Invoice2PdfService._formatDate(invoice.dueDate),
                        style: pw.TextStyle(font: fontBold, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 10),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey300),
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        'Description',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Qty',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Rate',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Amount',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 14),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        invoice.itemName,
                        style: pw.TextStyle(font: font, fontSize: 11),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        invoice.itemQuantity.toString(),
                        style: pw.TextStyle(font: font, fontSize: 11),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        Invoice2PdfService._formatCurrency(invoice.itemPrice, invoice.currency),
                        style: pw.TextStyle(font: font, fontSize: 11),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        Invoice2PdfService._formatCurrency(
                          invoice.itemPrice * invoice.itemQuantity,
                          invoice.currency,
                        ),
                        style: pw.TextStyle(font: font, fontSize: 11),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                width: double.infinity,
                height: 1,
                color: PdfColors.grey200,
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: 180,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Subtotal',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 11,
                                color: PdfColors.grey600,
                              ),
                            ),
                            pw.Text(
                              Invoice2PdfService._formatCurrency(
                                invoice.itemPrice * invoice.itemQuantity,
                                invoice.currency,
                              ),
                              style: pw.TextStyle(font: font, fontSize: 11),
                            ),
                          ],
                        ),
                        if (invoice.tax > 0) ...[
                          pw.SizedBox(height: 6),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Tax (${invoice.tax}%)',
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 11,
                                  color: PdfColors.grey600,
                                ),
                              ),
                              pw.Text(
                                Invoice2PdfService._formatCurrency(
                                  invoice.totalAmount -
                                      (invoice.itemPrice * invoice.itemQuantity),
                                  invoice.currency,
                                ),
                                style: pw.TextStyle(font: font, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                        pw.SizedBox(height: 10),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              top: pw.BorderSide(color: PdfColors.grey300),
                            ),
                          ),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Total',
                                style: pw.TextStyle(font: fontBold, fontSize: 14),
                              ),
                              pw.Text(
                                Invoice2PdfService._formatCurrency(
                                  invoice.totalAmount,
                                  invoice.currency,
                                ),
                                style: pw.TextStyle(font: fontBold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (invoice.note.isNotEmpty) ...[
                pw.SizedBox(height: 40),
                pw.Text(
                  'Notes',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey500,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  invoice.note,
                  style: pw.TextStyle(font: font, fontSize: 11),
                ),
              ],
              if (Invoice2PdfService._buildSignature(invoice, font) != null)
                Invoice2PdfService._buildSignature(invoice, font)!,
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 11,
                    color: PdfColors.grey500,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
