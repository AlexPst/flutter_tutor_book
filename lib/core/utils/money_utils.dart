int parseRublesToKopecks(String input) {
  final cleaned = input.replaceAll(',', '.').replaceAll(' ', '').trim();
  if (cleaned.isEmpty) return 0;
  final value = double.tryParse(cleaned) ?? 0;
  return (value * 100).round();
}

String formatKopecks(int kopekcs) {
  final rub = kopekcs ~/ 100;
  final rest = kopekcs % 100;
  if (rest == 0) return '$rub ₽';
  return '$rub,${rest.toString().padLeft(2, '0')} ₽';
}
