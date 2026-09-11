import 'package:flutter/material.dart';
import 'package:flutter_tutor_book/shared/widgets/empty_state.dart';

class WeekScreen extends StatelessWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Неделя')),
      body: const EmptyState(
        title: 'Календарь недели',
        description: 'Здесь будет расписание занятий',
        icon: Icons.calendar_view_week_outlined,
      ),
    );
  }
}
