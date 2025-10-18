import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/data/repo_impl/language_preferences_repo_impl.dart';
import 'package:swardenapp/app/data/services/preferences_service.dart';

final languagePreferencesRepoProvider = Provider<LanguagePreferencesRepo>(
  (ref) => LanguagePreferencesRepoImpl(ref.watch(preferencesServiceProvider)),
);

abstract class LanguagePreferencesRepo {
  AppLocale? getSavedLocale();

  Future<bool> saveLocale(AppLocale locale);

  Future<bool> clearLocale();

  AppLocale getDeviceLocale();
}
