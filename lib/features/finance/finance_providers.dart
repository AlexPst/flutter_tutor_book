import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/finance_repository.dart';

DateTime _monthStart(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

DateTime _monthEnd(DateTime date) {
  return DateTime(date.year, date.month + 1, 1);
}

final currentMonthStartProvider = Provider<DateTime>((ref) {
  return _monthStart(DateTime.now());
});

final monthFinanceProvider = StreamProvider<MonthFinance>((ref) {
  final start = ref.watch(currentMonthStartProvider);
  final end = _monthEnd(start);
  return ref.watch(financeRepositoryProvider).watchMonth(start, end);
});

final balanceProvider = StreamProvider<List<StudentBalanceRow>>((ref) {
  return ref.watch(financeRepositoryProvider).watchBalance();
});
