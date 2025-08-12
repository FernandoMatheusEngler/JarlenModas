import 'package:flutter/material.dart';

class AppConsts {
  // Nome do App
  static const String appName = "Jarlen Modas";

  // Cores principais
  static const Color primaryColor = Color.fromARGB(255, 69, 111, 224);
  static const Color secondaryColor = Color.fromARGB(255, 214, 214, 214);
  static const Color primaryColorText = Colors.black;
  static const Color borderColor = Color(0xFF1E3A8A);
  static const String pathLogoEnterprise = 'assets/images/logo_empresa.png';
  static const String pathBackgroundImage = 'assets/images/backgroud-image.png';
  static const String pathLogoEnterpriseNav =
      'assets/images/logo_empresa_nav.png';
  static const Color exitColor = Colors.white70;
  // Tema global
  static ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16),
    ),
    useMaterial3: true,
  );
}
