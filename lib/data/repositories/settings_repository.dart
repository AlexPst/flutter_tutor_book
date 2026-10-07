import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _kCurrency = 'currency_symbol';
  static const _kOnboardingDone = 'onboarding_done';

  String get currencySymbol => _prefs.getString(_kCurrency) ?? '₽';

  Future<void> setCurrencySymbol(String symbol) {
    return _prefs.setString(_kCurrency, symbol);
  }

  bool get onboardingDone => _prefs.getBool(_kOnboardingDone) ?? false;

  Future<void> setOnboardingDone(bool done) {
    return _prefs.setBool(_kOnboardingDone, done);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError(
    'SettingsRepositoryProvider must be overridden in the root of the app',
  );
});
