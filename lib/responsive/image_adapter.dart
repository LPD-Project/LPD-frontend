import 'package:flutter/material.dart';

class AdaptiveImageSize {
  const AdaptiveImageSize();

  double getadaptiveImageSize(BuildContext context, dynamic value) {
    return (value / 1080) * MediaQuery.of(context).size.width;
  }
}
