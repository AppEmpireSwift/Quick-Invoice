import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core.dart';

const _loadingDelay = Duration(seconds: 2);

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!kReleaseMode) await Future.delayed(_loadingDelay);
      Route route;
      if (OnBoardingHelper.showOnBoarding) {
        route = Boarding.route();
      } else {
        route = Home.route();
      }
      if (!mounted) return;
      //todo your router. for stage 2
      Navigator.pushReplacement(context, route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Core.splashPage;
  }
}
