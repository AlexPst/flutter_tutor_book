import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/db_provider.dart';

class PaymentRepository {
  PaymentRepository(this._db);
  final AppDatabase _db;

  Stream<List<Payment>> watchByStudent(int studentId) {
    return (_db.select(_db.payments)
          ..where((t) => t.studentId.equals(studentId))
          ..orderBy([(t) => OrderingTerm.desc(t.paidAt)]))
        .watch();
  }

  Future<int> add({
    required int studentId,
    required int amount,
    DateTime? paidAt,
    String? note,
  }) {
    return _db
        .into(_db.payments)
        .insert(
          PaymentsCompanion.insert(
            studentId: studentId,
            amount: amount,
            paidAt: paidAt == null ? const Value.absent() : Value(paidAt),
            note: Value(note),
          ),
        );
  }

  Future<void> delete(int id) {
    return (_db.delete(_db.payments)..where((t) => t.id.equals(id))).go();
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>(((ref) {
  return PaymentRepository(ref.watch(appDatabaseProvider));
}));
