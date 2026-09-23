import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tutor_book/data/database/app_database.dart';
import 'package:flutter_tutor_book/data/repositories/student_repository.dart';

final activeStudentProvider = StreamProvider<List<Student>>(((ref) {
  return ref.watch(studentRepositoryProvider).watchActive();
}));
