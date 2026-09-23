import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/lesson_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/student_repository.dart';

final studentByIdProvider = StreamProvider.family<Student?, int>((ref, id) {
  return ref.watch(studentRepositoryProvider).watchById(id);
});

final studentBalanceProvider = StreamProvider.family<StudentBalance, int>((
  ref,
  id,
) {
  return ref.watch(studentRepositoryProvider).watchBalance(id);
});

final lessonsByStudentProvider = StreamProvider.family<List<Lesson>, int>((
  ref,
  id,
) {
  return ref.watch(lessonRepositoryProvider).watchByStudent(id);
});

final paymentsByStudentProvider = StreamProvider.family<List<Payment>, int>((
  ref,
  id,
) {
  return ref.watch(paymentRepositoryProvider).watchByStudent(id);
});
