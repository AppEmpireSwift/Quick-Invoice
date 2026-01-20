import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_wa_skeleton/style/style.dart';

class Tab1 extends StatelessWidget {
  const Tab1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tab1', style: TextStyles.title3Emphasized),
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 16.r,
      ),
      body: ListView(padding: EdgeInsets.all(16).r, children: [Text('Tab1')]),
    );
  }
}
