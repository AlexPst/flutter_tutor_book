import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/lesson_repository.dart';
import 'week_lesson_row.dart';

class WeekDaySection extends StatelessWidget {
  const WeekDaySection({
    super.key,
    required this.date,
    required this.items,
    required this.onTapLesson,
  });

  final DateTime date;
  final List<LessonWithStudent> items;
  final void Function(LessonWithStudent) onTapLesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('EEEE, d MMMM', 'ru');
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    final label = df.format(date);
    final title = label.isEmpty
        ? label
        : label[0].toUpperCase() + label.substring(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isToday
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Сегодня',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'Нет уроков',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          )
        else
          for (final item in items) ...[
            WeekLessonRow(item: item, onTap: () => onTapLesson(item)),
          ],
      ],
    );
  }
}
