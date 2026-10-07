import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_tutor_book/data/repositories/settings_repository.dart';

class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier(this._repo) : super(_repo.currencySymbol);

  final SettingsRepository _repo;

  Future<void> set(String value) async {
    await _repo.setCurrencySymbol(value);
    state = value;
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  return CurrencyNotifier(ref.watch(settingsRepositoryProvider));
});
