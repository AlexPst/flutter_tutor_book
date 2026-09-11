import 'package:flutter/material.dart';
import 'package:flutter_tutor_book/shared/widgets/empty_state.dart';
import 'package:go_router/go_router.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сегодня'),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: const EmptyState(
        title: 'На сегодня занятий нет',
        description: 'Добавь первое занятие на вкладке "Неделя"',
        icon: Icons.event_available_outlined,
      ),
    );
  }
}
