import 'package:flutter/material.dart';

/// Drecera per accedir als estils de text del tema
extension TextStylesExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextStyle? get themeBL => textTheme.bodyLarge;
  TextStyle? get themeBM => textTheme.bodyMedium;
  TextStyle? get themeBS => textTheme.bodySmall;

  TextStyle? get themeTL => textTheme.titleLarge;
  TextStyle? get themeTM => textTheme.titleMedium;
  TextStyle? get themeTS => textTheme.titleSmall;

  TextStyle? get themeLL => textTheme.labelLarge;
  TextStyle? get themeLM => textTheme.labelMedium;
  TextStyle? get themeLS => textTheme.labelSmall;

  TextStyle? get themeDL => textTheme.displayLarge;
  TextStyle? get themeDM => textTheme.displayMedium;
  TextStyle? get themeDS => textTheme.displaySmall;

  TextStyle? get themeHL => textTheme.headlineLarge;
  TextStyle? get themeHM => textTheme.headlineMedium;
  TextStyle? get themeHS => textTheme.headlineSmall;
}
