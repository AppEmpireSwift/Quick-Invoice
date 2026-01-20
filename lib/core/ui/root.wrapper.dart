import 'package:flutter/material.dart';

import '../core.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  static Route route() => MaterialPageRoute(builder: (_) => const Home());

  @override
  Widget build(BuildContext context) {
    return Core.homePage;
  }
}
