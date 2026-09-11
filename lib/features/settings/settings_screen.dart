import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Настройки")),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text("Валюта"),
            subtitle: Text("₽"),
          ),
          ListTile(
            leading: Icon(Icons.file_download_done_outlined),
            title: Text("Экспорт данных"),
            subtitle: Text("CSV, позже"),
          ),
        ],
      ),
    );
  }
}
