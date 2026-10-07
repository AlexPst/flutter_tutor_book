import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tutor_book/data/database/app_database.dart';
import 'package:flutter_tutor_book/data/database/db_provider.dart';
import 'package:intl/intl.dart';

class CsvExporter {
  CsvExporter(this._db);
  final AppDatabase _db;

  Future<String> exportLessonsCsv() async {
    final rows = await (_db.select(
      _db.lessons,
    )..orderBy([(t) => OrderingTerm.desc(t.startAt)])).get();

    final students = await _db.select(_db.students).get();
    final nameById = {for (final s in students) s.id: s.name};

    final df = DateFormat('yyyy-MM-dd HH:mm');
    final buf = StringBuffer();
    buf.writeln('date,student,status,duration_min,price_rub,note');
    for (final l in rows) {
      buf.writeln(
        [
          df.format(l.startAt),
          _escape(nameById[l.studentId] ?? '?'),
          l.status,
          l.durationMin.toString(),
          (l.price / 100).toStringAsFixed(2),
          _escape(l.note ?? ''),
        ].join(','),
      );
    }
    return buf.toString();
  }

  Future<String> exportPaymentsCsv() async {
    final rows = await (_db.select(
      _db.payments,
    )..orderBy([(t) => OrderingTerm.desc(t.paidAt)])).get();

    final students = await _db.select(_db.students).get();
    final nameById = {for (final s in students) s.id: s.name};

    final df = DateFormat('yyyy-MM-dd HH:mm');
    final buf = StringBuffer();
    buf.writeln('date,student,amount_rub,note');
    for (final p in rows) {
      buf.writeln(
        [
          df.format(p.paidAt),
          _escape(nameById[p.studentId] ?? '?'),
          (p.amount / 100).toStringAsFixed(2),
          _escape(p.note ?? ''),
        ].join(','),
      );
    }
    return buf.toString();
  }

  String _escape(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}

final csvExporterProvider = Provider<CsvExporter>((ref) {
  return CsvExporter(ref.watch(appDatabaseProvider));
});
