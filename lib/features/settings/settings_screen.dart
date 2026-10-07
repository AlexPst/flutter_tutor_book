import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tutor_book/data/database/db_provider.dart';
import 'package:flutter_tutor_book/data/export/csv_exporter.dart';
import 'package:flutter_tutor_book/data/export/export_service.dart';
import 'package:flutter_tutor_book/features/settings/settings_provider.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Настройки")),
      body: ListView(
        children: [
          _SectionHeader('Внешний вид'),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Валюта'),
            subtitle: Text(currency),
            onTap: () => _pickCurrency(context, ref, currency),
          ),
        ],
      ),
    );
  }
}

Future<void> _pickCurrency(
  BuildContext context,
  WidgetRef ref,
  String current,
) async {
  const options = ['₽', '\$', '€', '₸', '₴', '£'];
  final chosen = await showModalBottomSheet<String>(
    context: context,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in options)
            ListTile(
              title: Text(c),
              trailing: c == current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(c),
            ),
        ],
      ),
    ),
  );
  if (chosen != null) {
    await ref.read(currencyProvider.notifier).set(chosen);
  }
}

Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Удалить все данные?'),
      content: const Text(
        'Это удалит всех учеников, занятия и оплаты. Действие нельзя отменить.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  if (context.mounted) return;

  final db = ref.read(appDatabaseProvider);
  await db.delete(db.lessons).go();
  await db.delete(db.payments).go();
  await db.delete(db.students).go();

  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Все данные удалены')));
  }
}

Future<void> _exportPayments(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);

  try {
    final csv = await ref.read(csvExporterProvider).exportPaymentsCsv();
    final name =
        'payments_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final file = await ExportService().save(name, csv);
    await Clipboard.setData(ClipboardData(text: file.path));
    messenger.showSnackBar(
      SnackBar(content: Text('Сохранено: ${file.path} (путь саопирован)')),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Ошибка экспорта: $e')));
  }
}

Future<void> _exportLessons(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final csv = await ref.read(csvExporterProvider).exportLessonsCsv();
    final name =
        'lessons_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final file = await ExportService().save(name, csv);
    await Clipboard.setData(ClipboardData(text: file.path));
    messenger.showSnackBar(
      SnackBar(content: Text('Сохранено: ${file.path} (путь скопирован)')),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Ошибка экспорта: $e')));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.fromLTRB(16, 16, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
