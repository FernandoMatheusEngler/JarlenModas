import 'package:flutter/material.dart';

class DropDownSearchWidget<T> extends StatefulWidget {
  const DropDownSearchWidget({
    super.key,
    required this.sourceList,
    this.initialValue,
    this.placeholder,
    this.onChanged,
    this.textFunction,
    this.readOnly = false,
  });

  final List<T> sourceList;
  final T? initialValue;
  final String? placeholder;
  final void Function(T? value)? onChanged;
  final String Function(T)? textFunction;
  final bool readOnly;

  @override
  State<DropDownSearchWidget<T>> createState() =>
      _DropDownSearchWidgetState<T>();
}

class _DropDownSearchWidgetState<T> extends State<DropDownSearchWidget<T>> {
  T? selectedItem;
  final TextEditingController _searchCtrl = TextEditingController();
  List<T> filteredItems = [];

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initialValue;
    filteredItems = widget.sourceList;
  }

  void _openModal() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          void filter(String value) {
            setStateDialog(() {
              filteredItems = widget.sourceList
                  .where(
                    (item) => _getItemText(
                      item,
                    ).toLowerCase().contains(value.toLowerCase()),
                  )
                  .toList();
            });
          }

          final size = MediaQuery.of(context).size;

          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.55,
                maxHeight: size.height * 0.6,
                minWidth: 300,
                minHeight: 200,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.placeholder ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  // Campo de pesquisa
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: "Pesquisar...",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: filter,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Lista de itens
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isSelected = item == selectedItem;
                        return ListTile(
                          title: Text(_getItemText(item)),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                          onTap: () {
                            setState(() {
                              selectedItem = item;
                              widget.onChanged?.call(item);
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getItemText(T item) {
    if (widget.textFunction != null) return widget.textFunction!(item);
    return item.toString();
  }

  double _getHeight(Size size) {
    double height = size.height;
    if (height > 800) {
      return 52;
    } else if (height > 700) {
      return 50;
    } else if (height > 600) {
      return 49;
    } else if (height > 500) {
      return 48;
    } else if (height > 400) {
      return 46;
    }
    return 44;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.readOnly ? null : _openModal,
      child: Container(
        height: _getHeight(MediaQuery.of(context).size),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedItem != null
                    ? _getItemText(selectedItem as T)
                    : (widget.placeholder ?? "Selecione"),
                style: TextStyle(
                  color: selectedItem == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            if (selectedItem != null && !widget.readOnly)
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedItem = null;
                    widget.onChanged?.call(null);
                  });
                },
                child: const Icon(Icons.close, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
