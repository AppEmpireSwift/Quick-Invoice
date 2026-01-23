import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/ui.helper.dart';
import '../core/core.dart';
import '../style/style.dart';

late QuickInvoiceUIHelper quickInvoiceUIHelper;

class QuickInvoiceApp extends StatelessWidget {
  const QuickInvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    quickInvoiceUIHelper = QuickInvoiceUIHelper.of(context);
    return ScreenUtilInit(
      designSize: QICore.config.figmaDesignSize,
      minTextAdapt: false,
      useInheritedMediaQuery: true,
      builder: (context, _) {
        return CupertinoApp(
          title: QICore.config.appName,
          debugShowCheckedModeBanner: false,
          theme: cupertinoThemeBuilder(context),
          locale: const Locale('en'),
          localizationsDelegates: const [DefaultMaterialLocalizations.delegate],
          builder:
              (context, child) =>
                  KeyboardDismissOnTap(child: child ?? Container()),
          home: const QILoading(),
        );
      },
    );
  }
}
