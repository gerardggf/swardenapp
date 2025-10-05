import 'package:flutter/material.dart';
import 'package:swardenapp/app/core/constants/colors.dart';

/// Tema personalitzat per a l'aplicació
class SwardenTheme {
  static final ThemeData theme = ThemeData(
    scaffoldBackgroundColor: AppColors.secondary,
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: AppColors.primary),
      backgroundColor: AppColors.secondary,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        fontSize: 26,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.secondary;
      }),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: TextStyle(color: AppColors.primary),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
    cardColor: AppColors.primaryBg,
    cardTheme: CardThemeData(color: AppColors.primaryBg),
    popupMenuTheme: PopupMenuThemeData(color: AppColors.primaryBg),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.secondary;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(AppColors.primary),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.secondary;
        }
        return AppColors.primary;
      }),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.secondary,
      titleTextStyle: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primary.withAlpha(76),
      selectionHandleColor: AppColors.primary,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: AppColors.primary),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
    ),
  );
}
