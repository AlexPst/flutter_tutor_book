import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories/lesson_repository.dart';

DateTime _dayStart(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

final weekStartProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  return _dayStart(monday);
});

final lessonsForWeekProvider =
    StreamProvider.family<List<LessonWithStudent>, DateTime>((ref, weekStart) {
      final from = _dayStart(weekStart);
      final to = from.add(const Duration(days: 7));
      return ref.watch(lessonRepositoryProvider).watchForRange(from, to);
    });
