import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tutor_book/data/repositories/lesson_repository.dart';
import 'package:flutter_tutor_book/features/today/today_providers.dart';
import 'package:flutter_tutor_book/features/today/widgets/today_lesson_tile.dart';
import 'package:flutter_tutor_book/shared/widgets/empty_state.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final lessonAsync = ref.watch(lessonForDayProvider(today));
    final df = DateFormat('d, MMMM, EEEE', 'ru');
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Text(
                  df.format(today),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Обновить',
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      ref.read(todayRefreshProvider.notifier).state++,
                ),
              ],
            ),
          ),
          Expanded(
            child: lessonAsync.when(
              error: (e, _) => Center(child: Text('Ошибка: $e')),
              loading: () => const Center(child: CircularProgressIndicator()),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    title: 'На сегодня нет занятий',
                    icon: Icons.event_available_outlined,
                    description: 'Вы можете добавить занятие в расписание',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return TodayLessonTile(
                      item: item,
                      onTap: () => context.push('/students/${item.student.id}'),
                      onDone: () =>
                          _setStatus(ref, item.lesson.id, 'done', context),
                      onCancel: () =>
                          _setStatus(ref, item.lesson.id, 'canceled', context),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setStatus(
    WidgetRef ref,
    int lessonId,
    String status,
    BuildContext context,
  ) async {
    final repo = ref.read(lessonRepositoryProvider);
    final messendger = ScaffoldMessenger.of(context);
    await repo.updateStatus(lessonId, status);
    messendger.hideCurrentSnackBar();
    messendger.showSnackBar(
      SnackBar(
        content: Text(
          status == 'done'
              ? 'Занятие отмечено как выполненное'
              : 'Занятие отменено',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
