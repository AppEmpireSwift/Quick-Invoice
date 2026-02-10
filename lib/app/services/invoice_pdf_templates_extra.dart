part of 'invoice_2_pdf_service.dart';

extension _ExtraTemplates on Invoice2PdfService {
  static Future<Uint8List> generateMinimal(
    Invoice invoice,
    pw.Font font,
    pw.Font fontBold,
  ) async {
    final pdf = pw.Document();
    final company = await Invoice2PdfService._getCompanyInfo();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (company['name']!.isNotEmpty) ...[
                pw.Text(
                  company['name']!,
                  style: pw.TextStyle(font: fontBold, fontSize: 20),
                ),
                pw.SizedBox(height: 8),
              ],
              pw.Text(
                'Invoice',
                style: pw.TextStyle(font: fontBold, fontSize: 36),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '#${invoice.invoiceNumber}',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 14,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 48),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'To',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                            color: PdfColors.grey500,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoice.clientName,
                          style: pw.TextStyle(font: fontBold, fontSize: 14),
                        ),
                        if (invoice.clientPhoneNumber.isNotEmpty)
                          pw.Text(
                            invoice.clientPhoneNumber,
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 11,
                              color: PdfColors.grey600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Date: ${Invoice2PdfService._formatDate(invoice.invoiceDate)}',
                        style: pw.TextStyle(font: font, fontSize: 11),
                      ),
                      pw.Text(
                        'Due: ${Invoice2PdfService._formatDate(invoice.dueDate)}',
                        style: pw.TextStyle(font: font, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 48),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 12),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        'Item',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Qty',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Price',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 16),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey200),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        invoice.itemName,
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        invoice.itemQuantity.toString(),
                        style: pw.TextStyle(font: font, fontSize: 12),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        Invoice2PdfService._formatCurrency(invoice.itemPrice, invoice.currency),
                        style: pw.TextStyle(font: font, fontSize: 12),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        Invoice2PdfService._formatCurrency(
                          invoice.itemPrice * invoice.itemQuantity,
                          invoice.currency,
                        ),
                        style: pw.TextStyle(font: font, fontSize: 12),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
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
                        Invoice2PdfService._summaryRow(
                          'Subtotal',
                          Invoice2PdfService._formatCurrency(
                            invoice.itemPrice * invoice.itemQuantity,
                            invoice.currency,
                          ),
                          font,
                        ),
                        if (invoice.tax > 0)
                          Invoice2PdfService._summaryRow(
                            'Tax',
                            Invoice2PdfService._formatCurrency(
                              invoice.totalAmount -
                                  (invoice.itemPrice * invoice.itemQuantity),
                              invoice.currency,
                            ),
                            font,
                          ),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total',
                              style: pw.TextStyle(font: fontBold, fontSize: 16),
                            ),
                            pw.Text(
                              Invoice2PdfService._formatCurrency(
                                invoice.totalAmount,
                                invoice.currency,
                              ),
                              style: pw.TextStyle(font: fontBold, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (invoice.note.isNotEmpty) ...[
                pw.SizedBox(height: 48),
                pw.Text(
                  'Notes',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey500,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  invoice.note,
                  style: pw.TextStyle(font: font, fontSize: 11),
                ),
              ],
              if (Invoice2PdfService._buildSignature(invoice, font) != null)
                Invoice2PdfService._buildSignature(invoice, font)!,
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateBold(
    Invoice invoice,
    pw.Font font,
    pw.Font fontBold,
  ) async {
    final pdf = pw.Document();
    final company = await Invoice2PdfService._getCompanyInfo();

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
                color: PdfColors.black,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 48,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '#${invoice.invoiceNumber}',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 16,
                        color: PdfColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 32),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'FROM',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        if (company['name']!.isNotEmpty)
                          pw.Text(
                            company['name']!,
                            style: pw.TextStyle(font: fontBold, fontSize: 14),
                          ),
                        if (company['address']!.isNotEmpty)
                          pw.Text(
                            company['address']!,
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                        if (company['phone']!.isNotEmpty)
                          pw.Text(
                            company['phone']!,
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILL TO',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          invoice.clientName,
                          style: pw.TextStyle(font: fontBold, fontSize: 14),
                        ),
                        if (invoice.clientPhoneNumber.isNotEmpty)
                          pw.Text(
                            invoice.clientPhoneNumber,
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'DATE',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        Invoice2PdfService._formatDate(invoice.invoiceDate),
                        style: pw.TextStyle(font: fontBold, fontSize: 12),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        'DUE DATE',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
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
                color: PdfColors.black,
                padding: const pw.EdgeInsets.all(12),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'DESCRIPTION',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'QTY',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'RATE',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'AMOUNT',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300, width: 2),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        invoice.itemName,
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        invoice.itemQuantity.toString(),
                        style: pw.TextStyle(font: font, fontSize: 12),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        Invoice2PdfService._formatCurrency(invoice.itemPrice, invoice.currency),
                        style: pw.TextStyle(font: font, fontSize: 12),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        Invoice2PdfService._formatCurrency(
                          invoice.itemPrice * invoice.itemQuantity,
                          invoice.currency,
                        ),
                        style: pw.TextStyle(font: font, fontSize: 12),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: 200,
                    child: pw.Column(
                      children: [
                        Invoice2PdfService._summaryRow(
                          'Subtotal',
                          Invoice2PdfService._formatCurrency(
                            invoice.itemPrice * invoice.itemQuantity,
                            invoice.currency,
                          ),
                          font,
                        ),
                        if (invoice.tax > 0)
                          Invoice2PdfService._summaryRow(
                            'Tax (${invoice.tax}%)',
                            Invoice2PdfService._formatCurrency(
                              invoice.totalAmount -
                                  (invoice.itemPrice * invoice.itemQuantity),
                              invoice.currency,
                            ),
                            font,
                          ),
                        pw.SizedBox(height: 8),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(12),
                          color: PdfColors.black,
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'TOTAL',
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 14,
                                  color: PdfColors.white,
                                ),
                              ),
                              pw.Text(
                                Invoice2PdfService._formatCurrency(
                                  invoice.totalAmount,
                                  invoice.currency,
                                ),
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 14,
                                  color: PdfColors.white,
                                ),
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
                  'NOTES',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  invoice.note,
                  style: pw.TextStyle(font: font, fontSize: 11),
                ),
              ],
              if (Invoice2PdfService._buildSignature(invoice, font) != null)
                Invoice2PdfService._buildSignature(invoice, font)!,
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}

