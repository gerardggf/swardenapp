import 'package:flutter_riverpod/legacy.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/domain/repos/language_preferences_repo.dart';

/// Proveidor del controlador d'idioma de l'aplicació
final languageControllerProvider =
    StateNotifierProvider<LanguageController, AppLocale>((ref) {
      final repo = ref.watch(languagePreferencesRepoProvider);
      return LanguageController(repo);
    });

/// Controlador per gestionar l'idioma de l'aplicació
class LanguageController extends StateNotifier<AppLocale> {
  final LanguagePreferencesRepo _repo;

  LanguageController(this._repo) : super(_getInitialLocale(_repo)) {
    LocaleSettings.setLocale(state);
  }

  static AppLocale _getInitialLocale(LanguagePreferencesRepo repo) {
    final savedLocale = repo.getSavedLocale();
    if (savedLocale != null) {
      return savedLocale;
    }
    return repo.getDeviceLocale();
  }

  Future<void> changeLocale(AppLocale newLocale) async {
    await _repo.saveLocale(newLocale);
    state = newLocale;
    LocaleSettings.setLocale(newLocale);
  }

  Future<void> resetToDeviceLocale() async {
    await _repo.clearLocale();
    final deviceLocale = _repo.getDeviceLocale();
    state = deviceLocale;
    LocaleSettings.setLocale(deviceLocale);
  }
}
