import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories/lesson_repository.dart';

DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

final lessonForDayProvider =
    StreamProvider.family<List<LessonWithStudent>, DateTime>(((ref, day) {
      final from = _dayStart(day);
      final to = from.add(const Duration(days: 1));
      return ref.watch(lessonRepositoryProvider).watchForRange(from, to);
    }));

final todayProvider = Provider<DateTime>(((ref) {
  ref.watch(todayRefreshProvider);
  return _dayStart(DateTime.now());
}));

final todayRefreshProvider = StateProvider<int>((ref) => 0);
