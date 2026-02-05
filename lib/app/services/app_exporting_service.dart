import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/core.dart';
import '../../data/database.dart';

class AppExportingService {
  static Future<void> shareCsv(List<Invoice> invoices) async {
    final csv = _buildCsv(invoices);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoices.csv');
    await file.writeAsString(csv);
    await QIShareHelper.shareFiles(files: [XFile(file.path)]);
  }

  static Future<void> shareExcel(List<Invoice> invoices) async {
    final html = _buildHtmlTable(invoices);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoices.xls');
    await file.writeAsString(html);
    await QIShareHelper.shareFiles(files: [XFile(file.path)]);
  }

  static String _buildCsv(List<Invoice> invoices) {
    final buf = StringBuffer();
    buf.writeln('Invoice Number,Date,Due Date,Client,Item,Price,Quantity,Tax %,Total,Currency,Status');
    final df = DateFormat('yyyy-MM-dd');
    for (final inv in invoices) {
      buf.writeln(
        '${_esc(inv.invoiceNumber)},${df.format(inv.invoiceDate)},${df.format(inv.dueDate)},'
        '${_esc(inv.clientName)},${_esc(inv.itemName)},${inv.itemPrice},${inv.itemQuantity},'
        '${inv.tax},${inv.totalAmount},${inv.currency},${inv.status}',
      );
    }
    return buf.toString();
  }

  static String _buildHtmlTable(List<Invoice> invoices) {
    final df = DateFormat('yyyy-MM-dd');
    final buf = StringBuffer();
    buf.writeln('<html><body><table border="1">');
    buf.writeln('<tr><th>Invoice Number</th><th>Date</th><th>Due Date</th><th>Client</th>'
        '<th>Item</th><th>Price</th><th>Quantity</th><th>Tax %</th><th>Total</th><th>Currency</th><th>Status</th></tr>');
    for (final inv in invoices) {
      buf.writeln(
        '<tr><td>${inv.invoiceNumber}</td><td>${df.format(inv.invoiceDate)}</td><td>${df.format(inv.dueDate)}</td>'
        '<td>${inv.clientName}</td><td>${inv.itemName}</td><td>${inv.itemPrice}</td><td>${inv.itemQuantity}</td>'
        '<td>${inv.tax}</td><td>${inv.totalAmount}</td><td>${inv.currency}</td><td>${inv.status}</td></tr>',
      );
    }
    buf.writeln('</table></body></html>');
    return buf.toString();
  }

  static String _esc(String value) {
    if (value.contains(',') || value.contains('"')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
