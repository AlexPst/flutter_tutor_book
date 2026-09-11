import 'package:flutter/material.dart';
import 'package:flutter_tutor_book/shared/widgets/empty_state.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Финансы")),
      body: const EmptyState(
        title: "Доходов пока нет",
        description: "Отмечайте оплаты в карточке ученика",
        icon: Icons.account_balance_wallet_outlined,
      ),
    );
  }
}
