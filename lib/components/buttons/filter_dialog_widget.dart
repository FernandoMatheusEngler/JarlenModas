import 'package:flutter/material.dart';

class FilterDialogWidget extends StatelessWidget {
  const FilterDialogWidget({super.key, required this.child, this.validate});
  final Widget child;
  final bool Function()? validate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text('Filtros')),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        width: MediaQuery.of(context).size.width * 0.55,
        child: child,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancelar"),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (validate != null) {
              bool valid = validate!();
              if (!valid) return;
            }
            Navigator.of(context).pop(true);
          },
          child: const Text("Confirmar"),
        ),
      ],
    );
  }
}
