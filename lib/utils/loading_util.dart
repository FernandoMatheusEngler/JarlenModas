import 'package:flutter/material.dart';
import 'package:jarlenmodas/components/loading/loading_widget.dart';

class LoadingUtil {
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Impede o usuário de fechar o dialog
      builder: (BuildContext context) {
        return const LoadingWidget();
      },
    );
  }

  static void hideLoading(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      if (context is StatefulElement && context.state.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
