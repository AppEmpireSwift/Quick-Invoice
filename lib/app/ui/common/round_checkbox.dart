import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../utils/extensions.dart';

import '../../../gen/assets.gen.dart';
import '../../../style/style.dart';

const _iconRatio = 13 / 22;

class TristateRoundCheckbox extends StatelessWidget {
  final double size;
  final bool? value;
  final ValueChanged<bool?> onChanged;

  const TristateRoundCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.size,
  });

  void _toggleState() {
    if (value == null) {
      onChanged(true);
    } else if (value == false) {
      onChanged(null);
    } else {
      onChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color? borderColor;
    Color fillColor;
    Widget? icon;

    if (value == false) {
      fillColor = ColorStyles.primaryTxt;
      icon = SvgPicture.asset(Assets.vectors.statMinus, width: size * _iconRatio).whiteColor;
    } else if (value == true) {
      fillColor = ColorStyles.primary;
      icon = SvgPicture.asset(Assets.vectors.statCheckmark, width: size * _iconRatio).whiteColor;
    } else {
      borderColor = ColorStyles.gray2Dark;
      fillColor = Colors.transparent;
      icon = null;
    }

    return GestureDetector(
      onTap: _toggleState,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fillColor,
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
        ),
        child: Center(child: icon),
      ),
    );
  }
}
