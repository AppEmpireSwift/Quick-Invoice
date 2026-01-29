import 'package:flutter/cupertino.dart';

import 'ui/quick_invoice_privacy_policy.page.dart';
import 'ui/quick_invoice_terms_of_use.page.dart';

void openPrivacyPolicy(BuildContext context) {
  showCupertinoSheet(
    context: context,
    builder: (_) => const QuickInvoicePrivacyPolicyPage(),
  );
}

void openTermsOfUse(BuildContext context) {
  showCupertinoSheet(
    context: context,
    builder: (_) => const QuickInvoiceTermsOfUsePage(),
  );
}
