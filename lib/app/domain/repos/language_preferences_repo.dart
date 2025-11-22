import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/data/repo_impl/language_preferences_repo_impl.dart';
import 'package:swardenapp/app/data/services/preferences_service.dart';

/// Proveïdor del repositori de preferències d'idioma
final languagePreferencesRepoProvider = Provider<LanguagePreferencesRepo>(
  (ref) => LanguagePreferencesRepoImpl(ref.watch(preferencesServiceProvider)),
);

/// Repositori per gestionar les preferències d'idioma
abstract class LanguagePreferencesRepo {
  /// Obté l'idioma desat a les preferències
  AppLocale? getSavedLocale();

  /// Desa l'idioma a les preferències
  Future<bool> saveLocale(AppLocale locale);

  /// Esborra l'idioma desat a les preferències
  Future<bool> clearLocale();

  /// Obté l'idioma del dispositiu
  AppLocale getDeviceLocale();
}
