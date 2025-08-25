import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jarlenmodas/core/routers.dart';
import 'package:jarlenmodas/firebase_options.dart';
import 'package:jarlenmodas/utils/window_manager.dart';
import 'package:toastification/toastification.dart';
import 'core/consts.dart';

Future<void> main() async {
  WindowManegerUtils.initializeWindowsPlataform();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp.router(
        routerConfig: AllRouter.router,
        debugShowCheckedModeBanner: false,
        title: AppConsts.appName,
        theme: AppConsts.themeData,
      ),
    );
  }
}
