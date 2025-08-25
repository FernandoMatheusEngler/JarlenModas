import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class MessageHelper {
  static void showSuccessMessage(String message) {
    toastification.show(
      title: Text(message),
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 5),
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return RotationTransition(turns: animation, child: child);
      },
    );
  }

  static void showErrorMessage(String message) {
    toastification.show(
      title: Text(message),
      style: ToastificationStyle.flat,
      animationDuration: const Duration(milliseconds: 300),
      autoCloseDuration: const Duration(seconds: 5),
      animationBuilder: (context, animation, alignment, child) {
        return RotationTransition(turns: animation, child: child);
      },
    );
  }
}
