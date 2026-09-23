import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/money_utils.dart';
import '../../../data/database/app_database.dart';

class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    this.onTap,
    this.onLongPress,
  });

  final Lesson lesson;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  static const _statusLabels = {
    'planned': 'Запланировано',
    'done': 'Проведено',
    'cancelled': 'Отменено',
    'no_show': 'Не пришел',
  };

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (lesson.status) {
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
    final df = DateFormat('d MMM, HH:mm', 'ru');
    final theme = Theme.of(context);
    final color = _statusColor(context);

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      title: Text(df.format(lesson.startAt)),
      subtitle: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _statusLabels[lesson.status] ?? lesson.status,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ),
          const SizedBox(width: 8),
          if (lesson.durationMin > 0)
            Text('${lesson.durationMin} мин', style: theme.textTheme.bodySmall),
        ],
      ),
      trailing: Text(
        formatKopecks(lesson.price),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
