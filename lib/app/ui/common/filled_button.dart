import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WAFilledButton extends StatefulWidget {
  final FutureOr<void> Function()? onPressed;
  final Widget child;
  const WAFilledButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  State<WAFilledButton> createState() => _WAFilledButtonState();
}

class _WAFilledButtonState extends State<WAFilledButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      child: FilledButton(
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
