import 'package:flutter/material.dart';

import '../core.dart';

class Boarding extends StatelessWidget {
  const Boarding({super.key});

  static Route route() => MaterialPageRoute(builder: (_) => const Boarding());

  @override
  Widget build(BuildContext context) {
    return Core.boardingPage;
  }
}
