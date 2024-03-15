import 'package:flutter/material.dart';

class ResponsiveUserLayout extends StatelessWidget {
  final Widget desktopUser;
  final Widget mobileUser;

  const ResponsiveUserLayout(
      {required this.desktopUser, required this.mobileUser});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double mobileWidthLayout = 830;
      if (constraints.maxWidth < mobileWidthLayout) {
        return mobileUser;
      } else {
        return desktopUser;
      }
    });
  }
}
