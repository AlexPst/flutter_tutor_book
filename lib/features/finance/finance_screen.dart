import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tutor_book/core/utils/money_utils.dart';
import 'package:flutter_tutor_book/data/repositories/finance_repository.dart';
import 'package:flutter_tutor_book/features/finance/finance_providers.dart';
import 'package:flutter_tutor_book/shared/widgets/empty_state.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthAsync = ref.watch(monthFinanceProvider);
    final balanceAsync = ref.watch(balanceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Финансы')),
      body: ListView(
        children: [
          monthAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Ошибка загрузки данных: $e'),
            ),
            data: (m) => _MonthCard(month: m),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Баланс учеников',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          balanceAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Ошибка загрузки данных: $e'),
            ),
            data: (rows) {
              final nonZero = rows.where((r) => r.debt != 0).toList();
              if (nonZero.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: EmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Долгов нет',
                    description: 'Все ученики в плюсе',
                  ),
                );
              }
              return Column(
                children: [for (final row in nonZero) _BalanceTile(row: row)],
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.month});

  final MonthFinance month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('LLLL y', 'ru');
    final raw = df.format(DateTime.now());
    final title = raw.isEmpty ? raw : raw[0].toUpperCase() + raw.substring(1);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Metric(
                  label: 'Проведено',
                  value: formatKopecks(month.earned),
                  color: theme.colorScheme.primary,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Оплачено',
                  value: formatKopecks(month.paid),
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Text('Разница за месяц', style: theme.textTheme.bodyMedium),
                    const Spacer(),
                    Text(
                      formatKopecks(month.debt),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: month.debt >= 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(color: color)),
      ],
    );
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({required this.row});

  final StudentBalanceRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final owes = row.debt > 0;
    final color = owes ? theme.colorScheme.error : theme.colorScheme.primary;
    final label = owes ? 'Должен' : 'Переплата: ${formatKopecks(-row.debt)}';

    return ListTile(
      onTap: () => context.push('/students/${row.studentId}'),
      title: Text(row.name),
      subtitle: Text(
        'Проведено: ${formatKopecks(row.earned)}, Оплачено: ${formatKopecks(row.paid)}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(label, style: TextStyle(color: color)),
    );
  }
}
