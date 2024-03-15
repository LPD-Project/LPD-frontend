import 'package:flutter/material.dart';
import 'package:lpd/component/error_alert.dart';

class ResponsiveRegisterLayout extends StatelessWidget {
  final Widget desktopRegister;
  final Widget mobileRegister;

  const ResponsiveRegisterLayout(
      {required this.desktopRegister, required this.mobileRegister});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double mobileWidthLayout = 830;
      try {
        if (constraints.maxWidth < mobileWidthLayout) {
          return mobileRegister;
        } else {
          return desktopRegister;
        }
      } catch (e) {
        return ErrorWidget(e);
      }
    });
  }
}
