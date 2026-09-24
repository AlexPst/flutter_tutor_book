import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tutor_book/core/utils/money_utils.dart';
import 'package:flutter_tutor_book/data/repositories/lesson_repository.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';

class AddLessonSheet extends ConsumerStatefulWidget {
  const AddLessonSheet({super.key, required this.student});

  final Student student;

  static Future<void> show(BuildContext context, Student student) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddLessonSheet(student: student),
    );
  }

  @override
  ConsumerState<AddLessonSheet> createState() => _AddLessonSheetState();
}

class _AddLessonSheetState extends ConsumerState<AddLessonSheet> {
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  final _durationCtrl = TextEditingController(text: '60');
  late final TextEditingController _priceCtrl;
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    final rate = widget.student.rate;
    _priceCtrl = TextEditingController(
      text: rate > 0 ? (rate / 100).toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final startAt = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );

      await ref
          .read(lessonRepositoryProvider)
          .add(
            studentId: widget.student.id,
            startAt: startAt,
            durationMin: int.tryParse(_durationCtrl.text.trim()) ?? 60,
            price: parseRublesToKopecks(_priceCtrl.text),
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          );
    } catch (e) {
      if (!mounted) return;

      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ошибка: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final df = DateFormat('d MMMM y, EEEE', 'ru');

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Новое занятие', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(df.format(_date)),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _pickTime,
                child: Text(_time.format(context)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _durationCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Цена, ₽'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Сохранить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
