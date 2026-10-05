import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/money_utils.dart';
import '../../../data/repositories/lesson_repository.dart';

class WeekLessonRow extends StatelessWidget {
  const WeekLessonRow({super.key, required this.item, required this.onTap});
  final LessonWithStudent item;
  final VoidCallback onTap;

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (item.lesson.status) {
      case 'done':
        return scheme.primary;
      case 'cancelled':
        return scheme.outline;
      case 'no_show':
        return scheme.secondary;
      default:
        return scheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = DateFormat('HH:mm').format(item.lesson.startAt);
    final color = _statusColor(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsGeometry.fromLTRB(16, 6, 16, 6),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                time,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              width: 3,
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.student.name,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.student.subject != null &&
                      item.student.subject!.isNotEmpty)
                    Text(
                      item.student.subject!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (item.lesson.price > 0)
              Text(
                formatKopecks(item.lesson.price),
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}
