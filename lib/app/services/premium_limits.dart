import 'package:apphud_helper/apphud_helper.dart';

import '../../data/database.dart';

class PremiumLimits {
  static const int freeInvoicesPerMonth = 3;
  static const int freeClients = 5;

  static bool get isPremium => ApphudHelper.service.hasPremium == true;

  static Future<bool> canCreateInvoice() async {
    if (isPremium) return true;
    final invoices = await AppDatabase.instance.getAllInvoices();
    final now = DateTime.now();
    final thisMonth = invoices.where((i) =>
        i.invoiceDate.year == now.year && i.invoiceDate.month == now.month).length;
    return thisMonth < freeInvoicesPerMonth;
  }

  static Future<bool> canAddClient() async {
    if (isPremium) return true;
    final clients = await AppDatabase.instance.getAllClients();
    return clients.length < freeClients;
  }

  static bool canUseTemplate(String templateName) {
    if (isPremium) return true;
    return templateName == 'Classic';
  }

  static bool canExport() => isPremium;
}
