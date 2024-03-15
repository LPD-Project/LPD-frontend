import 'package:flutter/material.dart';

class AdaptiveIconSize {
  const AdaptiveIconSize();

  double getadaptiveIconSize(BuildContext context, dynamic value) {
    var size = (value / 1080) * MediaQuery.of(context).size.width;
    return size > 30 ? size : 30;
  }
}
