// home_screen.dart
import 'package:flutter/material.dart';
import 'package:jarlenmodas/core/consts.dart';
import 'package:jarlenmodas/widgets/layout_controller/layout_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LayoutWidget(content: HomePageContent());
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Bem-vindo ao ${AppConsts.appName}",
              style: TextStyle(
                color: AppConsts.primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
