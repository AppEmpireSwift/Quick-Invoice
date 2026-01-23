import 'package:flutter/material.dart';

class QIHomeIndicatorSpace extends StatelessWidget {
  const QIHomeIndicatorSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.of(context).viewPadding.bottom);
  }
}
