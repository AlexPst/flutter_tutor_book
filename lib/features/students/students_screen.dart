import 'package:flutter/material.dart';
import 'package:flutter_tutor_book/shared/widgets/empty_state.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ученики')),
      body: const EmptyState(
        title: "Пока нет учеников",
        description: "Нажтми " + ", чтобы добавить нового ученика",
        icon: Icons.people_outline,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
