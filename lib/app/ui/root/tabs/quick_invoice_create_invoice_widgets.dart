import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../style/quick_invoice_style.dart';

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  SignaturePainter(this.strokes);

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
  bool shouldRepaint(covariant SignaturePainter oldDelegate) => true;
}

class CreateInvoiceProgressIndicator extends StatelessWidget {
  final int currentStep;

  const CreateInvoiceProgressIndicator({super.key, required this.currentStep});

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

class CreateInvoiceInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? placeholder;

  const CreateInvoiceInputWidget({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
  });

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

class CreateInvoiceSelectableContainer extends StatelessWidget {
  final String label;
  final String? value;
  final String? placeholder;
  final VoidCallback onTap;
  final Widget? icon;

  const CreateInvoiceSelectableContainer({
    super.key,
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

class CreateInvoiceInlineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final TextInputType keyboardType;
  final Widget? suffix;

  const CreateInvoiceInlineField({
    super.key,
    required this.label,
    required this.controller,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
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
                if (suffix != null) ...[SizedBox(width: 8.r), suffix!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreateInvoiceReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const CreateInvoiceReviewRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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

Future<Uint8List?> strokesToImage(List<List<Offset>> strokes) async {
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

void showSignatureDialog({
  required BuildContext context,
  required Future<Uint8List?> Function(List<List<Offset>>) onStrokesToImage,
  required void Function(Uint8List?) onSignatureSaved,
}) {
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
                  SizedBox(
                    height: 200.h,
                    width: 200.h,
                    child: Container(
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
                            painter: SignaturePainter(tempStrokes),
                            size: Size.infinite,
                          ),
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
                            final image = await onStrokesToImage(tempStrokes);
                            onSignatureSaved(image);
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

void showCurrencyPicker({
  required BuildContext context,
  required String currentCurrency,
  required void Function(String) onCurrencySelected,
}) {
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
                    onCurrencySelected(currencies[index]);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(currencies[index], style: QuickInvoiceTextStyles.bodyRegular),
                        if (currentCurrency == currencies[index])
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

void showInvoiceDatePicker({
  required BuildContext context,
  required bool isInvoiceDate,
  required DateTime? invoiceDate,
  required DateTime? dueDate,
  required void Function(DateTime, bool) onDateSelected,
}) {
  final today = DateTime.now();
  showCupertinoModalPopup<void>(
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
                  onDateSelected(newDate, isInvoiceDate);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
