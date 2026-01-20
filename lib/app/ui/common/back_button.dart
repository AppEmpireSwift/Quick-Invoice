import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../style/style.dart';

class WABackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const WABackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 10.r),
        Center(
          child: IconButton(
            icon: RotatedBox(
              quarterTurns: 1,
              child: Icon(
                CupertinoIcons.chevron_down,
                color: ColorStyles.primaryTxt,
                size: 20,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(ColorStyles.white),
            ),
            onPressed: () {
              if (onPressed != null) return onPressed!.call();
              Navigator.maybePop(context);
            },
          ),
        ),
      ],
    );
  }
}
