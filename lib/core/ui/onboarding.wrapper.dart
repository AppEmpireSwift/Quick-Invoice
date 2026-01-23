import 'package:flutter/material.dart';

import '../core.dart';

class QIBoarding extends StatelessWidget {
  const QIBoarding({super.key});

  static Route route() => MaterialPageRoute(builder: (_) => const QIBoarding());

  @override
  Widget build(BuildContext context) {
    return QICore.boardingPage;
  }
}
