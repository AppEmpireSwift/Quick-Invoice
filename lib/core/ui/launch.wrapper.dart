import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core.dart';

const _loadingDelay = Duration(seconds: 2);

class QILoading extends StatefulWidget {
  const QILoading({super.key});

  @override
  State<QILoading> createState() => _QILoadingState();
}

class _QILoadingState extends State<QILoading> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!kReleaseMode) await Future.delayed(_loadingDelay);
      Route route;
      if (QIBoardingHelper.showOnBoarding) {
        route = QIBoarding.route();
      } else {
        route = QIHome.route();
      }
      if (!mounted) return;
      Navigator.pushReplacement(context, route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return QICore.splashPage;
  }
}
