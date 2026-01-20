import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../style/style.dart';

class SettingsSection extends StatelessWidget {
  final List<Widget> children;

  const SettingsSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18).r,
      child: Material(
        borderRadius: BorderRadius.circular(18).r,
        color: ColorStyles.white,
        child: Column(
          children:
              children
                  .expand(
                    (e) => [
                      e,
                      Divider(
                        indent: 16.r,
                        endIndent: 16.r,
                        height: 1,
                        thickness: 1,
                        color: ColorStyles.primaryWithOpacity,
                      ),
                    ],
                  )
                  .toList()
                ..removeLast(),
        ),
      ),
    );
  }
}
