import 'package:flutter/material.dart';

class ResponsiveEditUserLayout extends StatelessWidget {
  final Widget desktopEditUser;
  final Widget mobileEditUser;

  const ResponsiveEditUserLayout(
      {required this.desktopEditUser, required this.mobileEditUser});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double mobileWidthLayout = 830;
      if (constraints.maxWidth < mobileWidthLayout) {
        return mobileEditUser;
      } else {
        return desktopEditUser;
      }
    });
  }
}
