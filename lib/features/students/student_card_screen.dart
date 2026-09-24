import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/money_utils.dart';
import '../../data/repositories/lesson_repository.dart';
import '../../shared/widgets/empty_state.dart';
import 'student_card_providers.dart';
import 'widgets/add_lesson_sheet.dart';
import 'widgets/add_payment_sheet.dart';
import 'widgets/lesson_tile.dart';

class StudentCardScreen extends ConsumerWidget {
  const StudentCardScreen({super.key, required this.studentId});

  final int studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentByIdProvider(studentId));
    final balanceAsync = ref.watch(studentBalanceProvider(studentId));
    final lessonsAsync = ref.watch(lessonsByStudentProvider(studentId));

    return studentAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Ошибка: $e')),
      ),
      data: (student) {
        if (student == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Ученик не найден')),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(student.name)),
          body: ListView(
            children: [
              _Header(student: student),
              const Divider(height: 1),
              balanceAsync.when(
                loading: () => const SizedBox(height: 80),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Баланс: ошибка $e'),
                ),
                data: (b) => _BalanceBlock(
                  balance: b,
                  onPay: () => AddPaymentSheet.show(
                    context,
                    studentId: student.id,
                    prefillAmount: b.debt > 0 ? b.debt : 0,
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsetsGeometry.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Занятия',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Занятие'),
                      onPressed: () => AddLessonSheet.show(context, student),
                    ),
                  ],
                ),
              ),
              lessonsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Ошибка: $e'),
                ),
                data: (lessons) {
                  if (lessons.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: EmptyState(
                        icon: Icons.event_outlined,
                        title: 'Занятий пока нет',
                        description: 'Нажми «Занятие», чтобы добавить',
                        ),)
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.student});

  final dynamic student;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      if (student.subject != null && student.subject!.isNotEmpty)
        student.subject as String,
      if (student.phone != null && student.phone!.isNotEmpty)
        student.phone as String,
      if (student.rate > 0) 'Ставка: ${formatKopecks(student.rate as int)}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(student.name as String, style: theme.textTheme.headlineSmall),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceBlock extends StatelessWidget {
  const _BalanceBlock({required this.balance, required this.onPay});

  final dynamic balance;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final debt = balance.debt as int;
    final earned = balance.earned as int;
    final paid = balance.paid as int;

    final label = debt > 0
        ? "Долг : ${formatKopecks(debt)}"
        : debt > 0
        ? 'Переплата: ${formatKopecks(-debt)}'
        : 'Всё оплачено';

    final color = debt > 0
        ? theme.colorScheme.error
        : debt < 0
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  'Проведено: ${formatKopecks(earned)} * Оплачено: ${formatKopecks(paid)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          FilledButton.tonal(onPressed: onPay, child: const Text('Оплата')),
        ],
      ),
    );
  }
}
