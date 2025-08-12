import 'package:flutter/material.dart';
import 'package:jarlenmodas/widgets/layout_controller/layout_widget.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ClientPageFrm extends StatelessWidget {
  const ClientPageFrm({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutWidget(content: ClientPageFrmContent(cpfCliente: 0));
  }
}

class ClientPageFrmContent extends StatelessWidget {
  ClientPageFrmContent({super.key, required this.cpfCliente});

  final int cpfCliente;
  final _cpfClienteController = TextEditingController();
  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          cpfCliente == 0
              ? 'Cadastrar Cliente'
              : 'Editar Cliente #$this.cpfCliente',
        ),
      ),
      body: SizedBox(
        width: 300,
        child: TextField(
          controller: _cpfClienteController,
          keyboardType: TextInputType.number, // Mude para teclado numérico
          inputFormatters: [
            _cpfFormatter, // Aplique o formatador aqui
          ],
          decoration: const InputDecoration(
            labelText: 'CPF do Cliente',
            hintText: '___.___.___-__', // Dica para o formato
            border: OutlineInputBorder(),
          ),
          // Opcional: para ver o valor sem formatação
          onChanged: (text) {},
        ),
      ),
    );
  }
}
