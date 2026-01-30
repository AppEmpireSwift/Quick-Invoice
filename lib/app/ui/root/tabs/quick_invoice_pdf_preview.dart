import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../style/quick_invoice_style.dart';
import '../../../../data/database.dart';
import '../../../services/pdf_service.dart';
import '../../../services/premium_limits.dart';
import '../../premium/quick_invoice_main_paywall.page.dart';

class QuickInvoicePdfPreviewPage extends StatefulWidget {
  final Invoice invoice;
  final PdfTemplate template;

  const QuickInvoicePdfPreviewPage({super.key, required this.invoice, required this.template});

  @override
  State<QuickInvoicePdfPreviewPage> createState() => _QuickInvoicePdfPreviewPageState();
}

class _QuickInvoicePdfPreviewPageState extends State<QuickInvoicePdfPreviewPage> {
  PdfControllerPinch? _pdfController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final path = await PdfService.savePdfToTemp(widget.invoice, template: widget.template);
    if (mounted) {
      setState(() {
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openFile(path),
          viewportFraction: 0.7,
        );
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: QuickInvoiceColorStyles.bgSecondary,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Preview'),
        backgroundColor: QuickInvoiceColorStyles.white,
        automaticBackgroundVisibility: false,
        transitionBetweenRoutes: false,
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => PdfService.shareInvoice(widget.invoice, template: widget.template),
          child: Icon(CupertinoIcons.share, color: QuickInvoiceColorStyles.primary, size: 22.r),
        ),
      ),
      child: SafeArea(
        child:
            _loading || _pdfController == null
                ? const Center(child: CupertinoActivityIndicator())
                : PdfViewPinch(minScale: 0.6, controller: _pdfController!, padding: 16),
      ),
    );
  }
}

class TemplateSelectorModal extends StatefulWidget {
  final Function(PdfTemplate) onTemplateSelected;

  const TemplateSelectorModal({super.key, required this.onTemplateSelected});

  @override
  State<TemplateSelectorModal> createState() => _TemplateSelectorModalState();
}

class _TemplateSelectorModalState extends State<TemplateSelectorModal> {
  PdfTemplate _selectedTemplate = PdfTemplate.classic;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: QuickInvoiceColorStyles.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 8.r, bottom: 16.r),
              width: 40.r,
              height: 4.r,
              decoration: BoxDecoration(
                color: QuickInvoiceColorStyles.separator,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              child: Text('Select Template', style: QuickInvoiceTextStyles.title3Emphasized),
            ),
            SizedBox(height: 24.r),
            SizedBox(
              height: 160.r,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.r),
                children: [
                  _TemplateOption(
                    name: 'Classic',
                    template: PdfTemplate.classic,
                    isSelected: _selectedTemplate == PdfTemplate.classic,
                    onTap: () => setState(() => _selectedTemplate = PdfTemplate.classic),
                  ),
                  SizedBox(width: 12.r),
                  _TemplateOption(
                    name: 'Modern',
                    template: PdfTemplate.modern,
                    isSelected: _selectedTemplate == PdfTemplate.modern,
                    isLocked: !PremiumLimits.isPremium,
                    onTap: () {
                      if (!PremiumLimits.isPremium) {
                        Navigator.pop(context);
                        QuickInvoiceMainPaywallPage.show(context);
                        return;
                      }
                      setState(() => _selectedTemplate = PdfTemplate.modern);
                    },
                  ),
                  SizedBox(width: 12.r),
                  _TemplateOption(
                    name: 'Minimal',
                    template: PdfTemplate.minimal,
                    isSelected: _selectedTemplate == PdfTemplate.minimal,
                    isLocked: !PremiumLimits.isPremium,
                    onTap: () {
                      if (!PremiumLimits.isPremium) {
                        Navigator.pop(context);
                        QuickInvoiceMainPaywallPage.show(context);
                        return;
                      }
                      setState(() => _selectedTemplate = PdfTemplate.minimal);
                    },
                  ),
                  SizedBox(width: 12.r),
                  _TemplateOption(
                    name: 'Bold',
                    template: PdfTemplate.bold,
                    isSelected: _selectedTemplate == PdfTemplate.bold,
                    isLocked: !PremiumLimits.isPremium,
                    onTap: () {
                      if (!PremiumLimits.isPremium) {
                        Navigator.pop(context);
                        QuickInvoiceMainPaywallPage.show(context);
                        return;
                      }
                      setState(() => _selectedTemplate = PdfTemplate.bold);
                    },
                  ),
                  SizedBox(width: 12.r),
                  _TemplateOption(
                    name: 'Elegance',
                    template: PdfTemplate.elegance,
                    isSelected: _selectedTemplate == PdfTemplate.elegance,
                    isLocked: !PremiumLimits.isPremium,
                    onTap: () {
                      if (!PremiumLimits.isPremium) {
                        Navigator.pop(context);
                        QuickInvoiceMainPaywallPage.show(context);
                        return;
                      }
                      setState(() => _selectedTemplate = PdfTemplate.elegance);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.r),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => widget.onTemplateSelected(_selectedTemplate),
                child: Container(
                  width: double.infinity,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: QuickInvoiceColorStyles.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Continue',
                      style: QuickInvoiceTextStyles.bodyEmphasized.copyWith(color: QuickInvoiceColorStyles.white),
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
}

class _TemplateOption extends StatelessWidget {
  final String name;
  final PdfTemplate template;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const _TemplateOption({
    required this.name,
    required this.template,
    required this.isSelected,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.r,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: QuickInvoiceColorStyles.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? QuickInvoiceColorStyles.primary : QuickInvoiceColorStyles.separator,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 100.r,
              decoration: BoxDecoration(
                color: QuickInvoiceColorStyles.bgSecondary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: _buildTemplatePreview(template),
            ),
            SizedBox(height: 8.r),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLocked) ...[
                  Icon(CupertinoIcons.lock_fill, size: 10.r, color: QuickInvoiceColorStyles.secondary),
                  SizedBox(width: 2.r),
                ],
                Flexible(
                  child: Text(
                    name,
                    style: QuickInvoiceTextStyles.caption2Emphasized.copyWith(
                      color: isLocked ? QuickInvoiceColorStyles.secondary : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatePreview(PdfTemplate template) {
    switch (template) {
      case PdfTemplate.classic:
        return Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 8.r,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: QuickInvoiceColorStyles.primary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 8.r),
              Container(
                height: 20.r,
                width: 40.r,
                decoration: BoxDecoration(
                  color: QuickInvoiceColorStyles.separator,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 8.r),
              ...List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 4.r),
                  child: Container(
                    height: 4.r,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: QuickInvoiceColorStyles.separator,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case PdfTemplate.modern:
        return Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 12.r,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: QuickInvoiceColorStyles.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                ),
              ),
              SizedBox(height: 8.r),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 20.r,
                      decoration: BoxDecoration(
                        color: QuickInvoiceColorStyles.separator,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.r),
                  Expanded(
                    child: Container(
                      height: 20.r,
                      decoration: BoxDecoration(
                        color: QuickInvoiceColorStyles.separator,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.r),
              Container(
                height: 30.r,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: QuickInvoiceColorStyles.separator,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ),
        );
      case PdfTemplate.minimal:
        return Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 8.r,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: QuickInvoiceColorStyles.black,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 8.r),
              ...List.generate(
                4,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 4.r),
                  child: Container(
                    height: 4.r,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: QuickInvoiceColorStyles.separator,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case PdfTemplate.bold:
        return Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16.r,
                width: double.infinity,
                color: QuickInvoiceColorStyles.black,
              ),
              SizedBox(height: 8.r),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 12.r,
                      decoration: BoxDecoration(
                        color: QuickInvoiceColorStyles.separator,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.r),
                  Expanded(
                    child: Container(
                      height: 12.r,
                      decoration: BoxDecoration(
                        color: QuickInvoiceColorStyles.separator,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.r),
              Container(
                height: 8.r,
                width: double.infinity,
                color: QuickInvoiceColorStyles.black,
              ),
              SizedBox(height: 4.r),
              Container(
                height: 20.r,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: QuickInvoiceColorStyles.separator,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ),
        );
      case PdfTemplate.elegance:
        return Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 10.r,
                    width: 30.r,
                    decoration: BoxDecoration(
                      color: QuickInvoiceColorStyles.black,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Container(
                    height: 8.r,
                    width: 20.r,
                    decoration: BoxDecoration(
                      color: QuickInvoiceColorStyles.separator,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.r),
              Container(
                height: 1,
                width: double.infinity,
                color: QuickInvoiceColorStyles.separator,
              ),
              SizedBox(height: 8.r),
              ...List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 4.r),
                  child: Container(
                    height: 4.r,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: QuickInvoiceColorStyles.separator,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6.r),
              Container(
                height: 1,
                width: double.infinity,
                color: QuickInvoiceColorStyles.separator,
              ),
            ],
          ),
        );
    }
  }
}
