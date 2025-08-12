import 'package:flutter/material.dart';
import 'package:jarlenmodas/core/consts.dart';

class ExitButton extends StatelessWidget {
  final VoidCallback onExitConfirmed;

  const ExitButton({super.key, required this.onExitConfirmed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Sair',
      onPressed: () {
        _showConfirmationDialog(context);
      },
      icon: const Icon(Icons.exit_to_app, color: AppConsts.exitColor),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Sair",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Tem certeza de que deseja sair?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Sim"),
              onPressed: () {
                Navigator.of(context).pop();
                onExitConfirmed();
              },
            ),
            TextButton(
              child: const Text("Não"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
