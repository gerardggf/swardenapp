import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/data/services/preferences_service.dart';
import 'package:swardenapp/app/domain/repos/language_preferences_repo.dart';

class LanguagePreferencesRepoImpl implements LanguagePreferencesRepo {
  final PreferencesService _preferencesService;

  LanguagePreferencesRepoImpl(this._preferencesService);

  @override
  AppLocale? getSavedLocale() {
    final savedLanguage = _preferencesService.getSavedLanguage();
    if (savedLanguage == null) return null;

    try {
      return AppLocale.values.firstWhere(
        (locale) => locale.languageCode == savedLanguage,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing saved locale: $e');
      }
      return null;
    }
  }

  @override
  Future<bool> saveLocale(AppLocale locale) async {
    try {
      return await _preferencesService.saveLanguage(locale.languageCode);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving locale: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> clearLocale() async {
    try {
      return await _preferencesService.clearLanguage();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing locale: $e');
      }
      return false;
    }
  }

  @override
  AppLocale getDeviceLocale() {
    try {
      final deviceLocale = Platform.localeName.split('_')[0];

      return AppLocale.values.firstWhere(
        (locale) => locale.languageCode == deviceLocale,
        orElse: () => AppLocale.en,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device locale: $e');
      }
      return AppLocale.en;
    }
  }
}
