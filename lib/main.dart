import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tutor_book/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await initializeDateFormatting('ru', "");
  runApp(const ProviderScope(child: TutorBookApp()));
}
