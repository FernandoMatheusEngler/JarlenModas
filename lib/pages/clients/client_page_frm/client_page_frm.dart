import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarlenmodas/cubits/client/client_cubit_frm/client_cubit_frm.dart';
import 'package:jarlenmodas/models/client/client_model.dart';
import 'package:jarlenmodas/services/client/client_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ClientPageFrm extends StatefulWidget {
  ClientPageFrm({super.key, ClientModel? client, required this.onSaved})
    : client =
          client ?? ClientModel(cpfClient: '', name: '', email: '', phone: '');

  final void Function(String) onSaved;
  final ClientModel? client;

  @override
  State<ClientPageFrm> createState() => _ClientPageFrmState();
}

class _ClientPageFrmState extends State<ClientPageFrm> {
  late final ClientPageFrmCubit cubit = ClientPageFrmCubit(
    service: ClientService(),
    clientModel: widget.client,
  );

  final FormGroup form = FormGroup({
    'cpfClient': FormControl<String>(validators: [Validators.required]),
    'name': FormControl<String>(validators: [Validators.required]),
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'phone': FormControl<String>(validators: [Validators.required]),
  });

  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  Future<void> _cancelEdition(BuildContext context) async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, 'home');
    }
  }

  Future<void> _saveClient() async {
    if (!form.valid || widget.client == null) return;
    widget.client!.cpfClient = form.control('cpfClient').value;
    widget.client!.name = form.control('name').value;
    widget.client!.email = form.control('email').value;
    widget.client!.phone = form.control('phone').value;

    cubit.save(widget.client!, widget.onSaved);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientPageFrmCubit, ClientPageFrmState>(
      bloc: cubit,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.client == null
                  ? 'Cadastrar Cliente'
                  : 'Editar Cliente ${widget.client!.cpfClient}',
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
                        ValidationMessage.required: (error) =>
                            'CPF é obrigatório',
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Name Field
                    ReactiveTextField<String>(
                      formControlName: 'name',
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      validationMessages: {
                        ValidationMessage.required: (error) =>
                            'Nome é obrigatório',
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

                    // Phone Field
                    ReactiveTextField<String>(
                      formControlName: 'phone',
                      decoration: const InputDecoration(
                        labelText: 'Telefone Celular',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validationMessages: {
                        ValidationMessage.required: (error) =>
                            'Telefone é obrigatório',
                      },
                      inputFormatters: [_phoneFormatter],
                    ),
                    const SizedBox(height: 24.0),
                    // Submit Button
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _cancelEdition(context),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _saveClient,
                          icon: const Icon(Icons.add),
                          label: const Text('Salvar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
