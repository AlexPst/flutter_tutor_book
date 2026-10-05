import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tutor_book/data/repositories/lesson_repository.dart';
import 'package:flutter_tutor_book/features/week/week_providers.dart';
import 'package:flutter_tutor_book/features/week/widgets/week_day_section.dart';
import 'package:flutter_tutor_book/shared/widgets/empty_state.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = ref.watch(weekStartProvider);
    final lessonsAsync = ref.watch(lessonsForWeekProvider(weekStart));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Неделя'),
        actions: [
          IconButton(
            tooltip: 'Текущая неделя',
            icon: const Icon(Icons.today_outlined),
            onPressed: () {
              final now = DateTime.now();
              final monday = now.subtract(Duration(days: now.weekday - 1));
              ref.read(weekStartProvider.notifier).state = DateTime(
                monday.year,
                monday.month,
                monday.day,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _WeekHeader(
            weekStart: weekStart,
            onPrev: () {
              ref.read(weekStartProvider.notifier).state = weekStart.subtract(
                const Duration(days: 7),
              );
            },
            onNext: () {
              ref.read(weekStartProvider.notifier).state = weekStart.add(
                const Duration(days: 7),
              );
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: lessonsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Ошибка загрузки данных: $e'),
              ),
              data: (all) {
                final byDay = <String, List<LessonWithStudent>>{};
                for (final item in all) {
                  final d = item.lesson.startAt;
                  final key = '${d.year}-${d.month}-${d.day}';
                  byDay.putIfAbsent(key, () => []).add(item);
                }
                return ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    for (var i = 0; i < 7; i++)
                      _buildDaySection(
                        context,
                        ref,
                        weekStart.add(Duration(days: i)),
                        byDay,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildDaySection(
  BuildContext context,
  WidgetRef ref,
  DateTime date,
  Map<String, List<LessonWithStudent>> byDay,
) {
  final key = '${date.year}-${date.month}-${date.day}';
  final items = byDay[key] ?? const <LessonWithStudent>[];
  return WeekDaySection(
    date: date,
    items: items,
    onTapLesson: (item) {
      context.push('/students/${item.student.id}');
    },
  );
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.weekStart,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime weekStart;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final end = weekStart.add(const Duration(days: 6));
    final df = DateFormat('d MMM', 'ru');
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev),
          Expanded(
            child: Center(
              child: Text(
                '${df.format(weekStart)} - ${df.format(end)}',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}
