import 'package:flutter/material.dart';

class HomeIndicatorSpace extends StatelessWidget {
  const HomeIndicatorSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.of(context).viewPadding.bottom);
  }
}
