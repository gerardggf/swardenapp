import 'package:flutter/material.dart';

extension SizedBoxWidgetDoubleExtension on double {
  SizedBox get w => SizedBox(
        width: this,
      );
  SizedBox get h => SizedBox(
        height: this,
      );
}

extension SizedBoxWidgetIntExtension on int {
  SizedBox get w => SizedBox(
        width: toDouble(),
      );
  SizedBox get h => SizedBox(
        height: toDouble(),
      );
}
