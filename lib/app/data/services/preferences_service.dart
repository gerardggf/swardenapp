import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swardenapp/app/core/global_providers.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider).requireValue;
  return PreferencesService(sharedPrefs);
});

/// Servei per gestionar preferències de l'aplicació
class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static const String _languageKey = 'app_language';

  String? getSavedLanguage() {
    return _prefs.getString(_languageKey);
  }

  Future<bool> saveLanguage(String languageCode) async {
    return await _prefs.setString(_languageKey, languageCode);
  }

  Future<bool> clearLanguage() async {
    return await _prefs.remove(_languageKey);
  }
}
