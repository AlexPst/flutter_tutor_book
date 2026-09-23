import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/db_provider.dart';

class StudentBalance {
  const StudentBalance({required this.earned, required this.paid});

  final int earned;
  final int paid;

  int get debt => earned - paid;
}

class StudentRepository {
  StudentRepository(this._db);
  final AppDatabase _db;

  Stream<Student?> watchById(int id) {
    return (_db.select(
      _db.students,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Stream<StudentBalance> watchBalance(int studentId) {
    final query = _db.customSelect(
      '''
       SELECT
        COALESCE((SELECT SUM(price) FROM lessons
                  WHERE student_id = ? AND status = 'done'), 0) AS earned,
        COALESCE((SELECT SUM(amount) FROM payments
                  WHERE student_id = ?), 0) AS paid
      ''',
      variables: [Variable.withInt(studentId), Variable.withInt(studentId)],
      readsFrom: {_db.lessons, _db.payments},
    );
    return query.watchSingle().map((row) {
      return StudentBalance(
        earned: row.read<int>('earned'),
        paid: row.read<int>('paid'),
      );
    });
  }

  Stream<List<Student>> watchActive() {
    return (_db.select(_db.students)
          ..where((t) => t.archived.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<Student?> byId(int id) {
    return (_db.select(
      _db.students,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> add({
    required String name,
    String? subject,
    String? phone,
    int rate = 0,
    String? note,
  }) {
    return _db
        .into(_db.students)
        .insert(
          StudentsCompanion.insert(
            name: name,
            subject: Value(subject),
            phone: Value(phone),
            rate: Value(rate),
            note: Value(note),
          ),
        );
  }

  Future<bool> updateStudent(Student s) {
    return _db.update(_db.students).replace(s);
  }

  Future<void> archive(int id) {
    return (_db.update(_db.students)..where((t) => t.id.equals(id))).write(
      const StudentsCompanion(archived: Value(true)),
    );
  }

  Future<void> unarchive(int id) {
    return (_db.update(_db.students)..where((t) => t.id.equals(id))).write(
      const StudentsCompanion(archived: Value(false)),
    );
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.lessons)..where((t) => t.studentId.equals(id))).go();
    await (_db.delete(_db.payments)..where((t) => t.studentId.equals(id))).go();
    await (_db.delete(_db.students)..where((t) => t.id.equals(id))).go();
  }
}

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(ref.watch(appDatabaseProvider));
});
