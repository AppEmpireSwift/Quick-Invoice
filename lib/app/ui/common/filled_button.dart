import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_invoice/style/color.style.dart';

class QIFilledButton extends StatefulWidget {
  final FutureOr<void> Function()? onPressed;
  final Widget child;
  const QIFilledButton({super.key, required this.onPressed, required this.child});

  @override
  State<QIFilledButton> createState() => _QIFilledButtonState();
}

class _QIFilledButtonState extends State<QIFilledButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h.clamp(0, 52),
      child: FilledButton(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontSize: 16.sp.clamp(0, 24),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.43,
              color: ColorStyles.white,
            ),
          ),
          backgroundColor: WidgetStateProperty.all(Color.fromRGBO(0, 136, 255, 1)),
        ),
        onPressed: handleOnPressed,
        child: isLoading ? CircularProgressIndicator.adaptive() : widget.child,
      ),
    );
  }

  Future<void> handleOnPressed() async {
    if (isLoading) return;
    HapticFeedback.mediumImpact();
    try {
      var result = widget.onPressed?.call();

      if (result is! Future) {
        return result;
      }

      switchState(true);
      await result;

      switchState(false);
    } catch (_) {
      switchState(false);
      rethrow;
    }
  }

  void switchState(bool loading) {
    if (isLoading == loading) return;
    if (!mounted) return;
    setState(() {
      isLoading = loading;
    });
  }
}
