import 'package:flutter/material.dart';

import '../core.dart';

class QIHome extends StatelessWidget {
  const QIHome({super.key});

  static Route route() => MaterialPageRoute(builder: (_) => const QIHome());

  @override
  Widget build(BuildContext context) {
    return QICore.homePage;
  }
}
