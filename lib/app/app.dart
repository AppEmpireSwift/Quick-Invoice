import 'package:flutter/cupertino.dart';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_wa_skeleton/core/services/ui.helper.dart';

import '../core/core.dart';
import '../style/style.dart';

late UIHelper uiHelper;

class WASkeleton extends StatelessWidget {
  const WASkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    uiHelper = UIHelper.of(context);
    return ScreenUtilInit(
      designSize: Core.config.figmaDesignSize,
      minTextAdapt: false,
      useInheritedMediaQuery: true,
      builder: (context, _) {
        return CupertinoApp(
          title: Core.config.appName,
          debugShowCheckedModeBanner: false,
          theme: cupertinoThemeBuilder(context),
          locale: const Locale('en'),
          builder: (context, child) => KeyboardDismissOnTap(child: child ?? Container()),
          home: const Loading(),
        );
      },
    );
  }
}
