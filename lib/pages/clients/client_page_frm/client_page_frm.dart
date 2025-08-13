import 'package:flutter/material.dart';
import 'package:jarlenmodas/widgets/layout_controller/layout_widget.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:reactive_forms/reactive_forms.dart';

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

  // Reactive Form definition
  final FormGroup form = FormGroup({
    'cpfClient': FormControl<String>(validators: [Validators.required]),
    'nome': FormControl<String>(validators: [Validators.required]),
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'telefone': FormControl<String>(validators: [Validators.required]),
  });

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
          cpfCliente == 0 ? 'Cadastrar Cliente' : 'Editar Cliente #$cpfCliente',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ReactiveForm(
            formGroup: form,
            child: Column(
              children: <Widget>[
                // CPF Field
                ReactiveTextField<String>(
                  formControlName: 'cpfClient',
                  decoration: const InputDecoration(
                    labelText: 'CPF do Cliente',
                    hintText: '___.___.___-__',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cpfFormatter],
                  validationMessages: {
                    ValidationMessage.required: (error) => 'CPF é obrigatório',
                  },
                ),
                const SizedBox(height: 16.0),

                // Nome Field
                ReactiveTextField<String>(
                  formControlName: 'nome',
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validationMessages: {
                    ValidationMessage.required: (error) => 'Nome é obrigatório',
                  },
                ),
                const SizedBox(height: 16.0),

                // Email Field
                ReactiveTextField<String>(
                  formControlName: 'email',
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validationMessages: {
                    ValidationMessage.required: (error) =>
                        'E-mail é obrigatório',
                    ValidationMessage.email: (error) =>
                        'Informe um e-mail válido',
                  },
                ),
                const SizedBox(height: 16.0),

                // Telefone Field
                ReactiveTextField<String>(
                  formControlName: 'telefone',
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validationMessages: {
                    ValidationMessage.required: (error) =>
                        'Telefone é obrigatório',
                  },
                ),
                const SizedBox(height: 24.0),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (form.valid) {
                      // Aqui você pode manipular os dados do form
                      final client = form.value;
                      print(client); // Ou enviar para o serviço de backend
                    } else {
                      form.markAllAsTouched();
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
