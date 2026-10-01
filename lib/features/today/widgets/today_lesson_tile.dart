import 'package:flutter/material.dart';
import 'package:flutter_tutor_book/core/utils/money_utils.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/lesson_repository.dart';

class TodayLessonTile extends StatelessWidget {
  const TodayLessonTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDone,
    required this.onCancel,
  });

  final LessonWithStudent item;
  final VoidCallback onTap;
  final VoidCallback onDone;
  final VoidCallback onCancel;

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (item.lesson.status) {
      case 'done':
        return scheme.primary;
      case 'cancelled':
        return scheme.outline;
      case 'no_show':
        return scheme.error;

      default:
        return scheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lesson = item.lesson;
    final student = item.student;
    final time = DateFormat('HH:mm').format(lesson.startAt);
    final statusColor = _statusColor(context);
    final isPlanned = lesson.status == 'planned';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${lesson.durationMin} мин',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 3,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (student.subject != null && student.subject!.isNotEmpty)
                      Text(
                        student.subject!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (lesson.price > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    formatKopecks(lesson.price),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              if (isPlanned) ...[
                IconButton(
                  tooltip: 'Проведено',
                  icon: const Icon(Icons.check_circle_outline),
                  color: theme.colorScheme.primary,
                  onPressed: onCancel,
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
