import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowManegerUtils {
  static void initializeWindowsPlataform() {
    WidgetsFlutterBinding.ensureInitialized();
    windowManager.ensureInitialized();
    windowManager.setTitle("Jarlen Modas");
    windowManager.setIcon("assets/images/windows_apllication_icon.ico");
  }
}
