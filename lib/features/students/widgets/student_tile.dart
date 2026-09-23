import 'package:flutter/material.dart';

import '../../../core/utils/money_utils.dart';
import '../../../data/database/app_database.dart';

class StudentTile extends StatelessWidget {
  const StudentTile({super.key, required this.student, this.onTap});

  final Student student;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <String>[
      if (student.subject != null && student.subject!.isNotEmpty)
        student.subject!,
      if (student.rate > 0) formatKopecks(student.rate),
    ];
    final subtitle = parts.join(' . ');

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        child: Text(
          student.name.characters.first.toUpperCase(),
          style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
        ),
      ),
      title: Text(student.name),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
