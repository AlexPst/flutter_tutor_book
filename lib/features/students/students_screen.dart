import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_tutor_book/shared/widgets/empty_state.dart';

import '../../data/repositories/student_repository.dart';
import 'students_providers.dart';
import 'widgets/add_student_sheet.dart';
import 'widgets/student_tile.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(activeStudentProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ученики')),
      body: studentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (students) {
          if (students.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              title: 'Пока нет учеников',
              description: 'Нажми "+", чтобы добавить первого',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: students.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final s = students[index];
              return Dismissible(
                key: ValueKey(s.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.archive_outlined,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                onDismissed: (_) async {
                  final messenger = ScaffoldMessenger.of(context);
                  final repo = ref.read(studentRepositoryProvider);
                  await repo.archive(s.id);
                  messenger.hideCurrentSnackBar();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text("${s.name} в архиве"),
                      action: SnackBarAction(
                        label: 'Отменить',
                        onPressed: () => repo.unarchive(s.id),
                      ),
                    ),
                  );
                },

                child: StudentTile(student: s, onTap: () {}),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddStudentSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
