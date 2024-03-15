import 'package:flutter/material.dart';

class ResponsiveNavBarLayout extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget mobileNavBar;
  final Widget desktopNavBar;

  const ResponsiveNavBarLayout(
      {required this.mobileNavBar, required this.desktopNavBar});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double mobileWidthLayout = 610;
      if (constraints.maxWidth < mobileWidthLayout) {
        return mobileNavBar;
      } else {
        return desktopNavBar;
      }
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
