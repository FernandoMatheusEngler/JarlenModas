// layout_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarlenmodas/core/consts.dart';
import 'package:jarlenmodas/components/menu_itens/menu_item_widget.dart';

class LayoutWidget extends StatelessWidget {
  final Widget content;

  const LayoutWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use Scaffold para incluir AppBar
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                context.goNamed('home');
              },
              child: Image.asset(AppConsts.pathLogoEnterpriseNav, height: 50),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          const SizedBox(width: 250, child: MenuItensWidget()),
          Expanded(child: content),
        ],
      ),
    );
  }
}
