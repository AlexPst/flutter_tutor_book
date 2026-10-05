import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/db_provider.dart';

class MonthFinance {
  const MonthFinance({required this.earned, required this.paid});

  final int earned;
  final int paid;

  int get debt => earned - paid;
}

class StudentBalanceRow {
  const StudentBalanceRow({
    required this.studentId,
    required this.name,
    required this.earned,
    required this.paid,
  });
  final int studentId;
  final String name;
  final int earned;
  final int paid;
  int get debt => earned - paid;
}

class FinanceRepository {
  FinanceRepository(this._db);
  final AppDatabase _db;

  Stream<MonthFinance> watchMonth(DateTime from, DateTime to) {
    final q = _db.customSelect(
      '''
      SELECT
        COALESCE((SELECT SUM(price) FROM lessons
                  WHERE status = 'done'
                    AND start_at >= ? AND start_at < ?), 0) AS earned,
        COALESCE((SELECT SUM(amount) FROM payments
                  WHERE paid_at >= ? AND paid_at < ?), 0) AS paid
      ''',
      variables: [
        Variable.withDateTime(from),
        Variable.withDateTime(to),
        Variable.withDateTime(from),
        Variable.withDateTime(to),
      ],
      readsFrom: {_db.lessons, _db.payments},
    );
    return q.watchSingle().map((row) {
      return MonthFinance(
        earned: row.read<int>('earned'),
        paid: row.read<int>('paid'),
      );
    });
  }

  Stream<List<StudentBalanceRow>> watchBalance() {
    final q = _db.customSelect(
      '''
      SELECT
        s.id AS student_id,
        s.name AS name,
        COALESCE((SELECT SUM(price) FROM lessons
                  WHERE student_id = s.id AND status = 'done'), 0) AS earned,
        COALESCE((SELECT SUM(amount) FROM payments
                  WHERE student_id = s.id), 0) AS paid
      FROM students s
      WHERE s.archived = 0
      ORDER BY s.name
      ''',
      readsFrom: {_db.students, _db.lessons, _db.payments},
    );
    return q.watch().map((rows) {
      return rows.map((row) {
        return StudentBalanceRow(
          studentId: row.read<int>('student_id'),
          name: row.read<String>('name'),
          earned: row.read<int>('earned'),
          paid: row.read<int>('paid'),
        );
      }).toList();
    });
  }
}

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(ref.watch(appDatabaseProvider));
});
