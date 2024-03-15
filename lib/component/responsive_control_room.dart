import 'package:flutter/material.dart';

class ResponsiveControlRoomLayout extends StatelessWidget {
  final Widget desktopControRoomLayout;
  final Widget mobileControRoomLayout;

  const ResponsiveControlRoomLayout(
      {required this.desktopControRoomLayout,
      required this.mobileControRoomLayout});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double mobileWidthLayout = 1200;
      if (constraints.maxWidth < mobileWidthLayout) {
        return mobileControRoomLayout;
      } else {
        return desktopControRoomLayout;
      }
    });
  }
}
