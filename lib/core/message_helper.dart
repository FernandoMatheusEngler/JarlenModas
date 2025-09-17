import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class MessageHelper {
  /// Exibe uma mensagem de sucesso verde. ✅
  static void showSuccessMessage(BuildContext context, String message) {
    toastification.show(
      context: context, // O contexto é necessário para o show
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
      // Cores para o tema de sucesso
      primaryColor: Colors.white,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.check_circle_outline),
      // Animação personalizada que você já usava
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return RotationTransition(turns: animation, child: child);
      },
    );
  }

  /// Exibe uma mensagem de erro vermelha. ❌
  static void showErrorMessage(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
      // Cores para o tema de erro
      primaryColor: Colors.white,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.error_outline),
      // Animação personalizada
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return RotationTransition(turns: animation, child: child);
      },
    );
  }

  /// Exibe uma mensagem de aviso laranja. ⚠️
  static void showWarningMessage(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
      // Cores para o tema de aviso
      primaryColor: Colors.white,
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.warning_amber_rounded),
      // Animação personalizada
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return RotationTransition(turns: animation, child: child);
      },
    );
  }
}
