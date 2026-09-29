import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/db_provider.dart';

class LessonRepository {
  LessonRepository(this._db);

  final AppDatabase _db;

  Stream<List<Lesson>> watchByStudent(int studentId) {
    return (_db.select(_db.lessons)
          ..where(((t) => t.studentId.equals(studentId)))
          ..orderBy([(t) => OrderingTerm.desc(t.startAt)]))
        .watch();
  }

  Future<int> add({
    required int studentId,
    required DateTime startAt,
    required int durationMin,
    required int price,
    String? note,
    String status = 'planned',
  }) {
    return _db
        .into(_db.lessons)
        .insert(
          LessonsCompanion.insert(
            studentId: studentId,
            startAt: startAt,
            durationMin: Value(durationMin),
            price: Value(price),
            status: Value(status),
            note: Value(note),
          ),
        );
  }

  Future<void> updateStatus(int id, String status) {
    return (_db.update(_db.lessons)..where((t) => t.id.equals(id))).write(
      LessonsCompanion(status: Value(status)),
    );
  }

  Future<void> delete(int id) {
    return (_db.delete(_db.lessons)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<LessonWithStudent>> watchForRange(DateTime from, DateTime to) {
    final query =
        _db.select(_db.lessons).join([
            innerJoin(
              _db.students,
              _db.students.id.equalsExp(_db.lessons.studentId),
            ),
          ])
          ..where(_db.lessons.startAt.isBiggerOrEqualValue(from))
          ..where(_db.lessons.startAt.isSmallerThanValue(to))
          ..where(_db.students.archived.equals(false))
          ..orderBy([OrderingTerm.asc(_db.lessons.startAt)]);
    return query.watch().map((rows) {
      return rows.map((row) {
        return LessonWithStudent(
          lesson: row.readTable(_db.lessons),
          student: row.readTable(_db.students),
        );
      }).toList();
    });
  }
}

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepository(ref.watch(appDatabaseProvider));
});

class LessonWithStudent {
  const LessonWithStudent({required this.lesson, required this.student});

  final Lesson lesson;
  final Student student;
}
