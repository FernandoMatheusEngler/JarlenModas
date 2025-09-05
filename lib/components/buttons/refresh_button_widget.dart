import 'package:flutter/material.dart';
import 'package:jarlenmodas/core/consts.dart';

class RefreshButtonWidget extends StatefulWidget {
  const RefreshButtonWidget({
    super.key,
    required this.onPressed,
    this.readonly = false,
  });

  final void Function()? onPressed;
  final bool readonly;

  @override
  State<RefreshButtonWidget> createState() => _RefreshButtonWidgetState();
}

class _RefreshButtonWidgetState extends State<RefreshButtonWidget> {
  bool hovered = false;
  bool valid = true;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Atualizar',
      child: Material(
        child: InkWell(
          onTap: widget.onPressed,
          onHover: (bool hover) => setState(() => hovered = hover),
          mouseCursor: SystemMouseCursors.click,
          child: Container(
            width: AppConsts.ismallIconButtonWidth,
            height: AppConsts.smallButtonHeight,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              color: hovered ? Colors.blue.shade900 : Colors.blue.shade800,
            ),
            child: const Icon(
              Icons.refresh,
              size: 18,
              color: AppConsts.primaryColorIcon,
            ),
          ),
        ),
      ),
    );
  }
}
