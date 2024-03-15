import 'package:flutter/material.dart';

class AdaptiveTextSize {
  const AdaptiveTextSize();

  double getadaptiveTextSize(BuildContext context, dynamic value) {
    var size = (value / 1080) * MediaQuery.of(context).size.width;
    if (size > 16) {
      return (value / 1080) * MediaQuery.of(context).size.width >= 25
          ? 25
          : (value / 1080) * MediaQuery.of(context).size.width;
    } else {
      return 20;
    } // 720 is medium screen height
  }
}
