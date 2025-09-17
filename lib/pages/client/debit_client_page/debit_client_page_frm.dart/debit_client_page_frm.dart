import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jarlenmodas/components/drop_down/drop_down_search_widget.dart';
import 'package:jarlenmodas/core/message_helper.dart';
import 'package:jarlenmodas/cubits/client/client_cubit/client_cubit.dart';
import 'package:jarlenmodas/cubits/client/debit_client_cubit/debit_client_cubit.dart';
import 'package:jarlenmodas/models/client/client_model/client_filter.dart';
import 'package:jarlenmodas/models/client/client_model/client_model.dart';
import 'package:jarlenmodas/models/client/debit_client_model/debit_client_filter.dart';
import 'package:jarlenmodas/services/clients/client_service/client_service.dart';
import 'package:jarlenmodas/services/clients/debit_clients_service/debit_client_service.dart';
import 'package:jarlenmodas/components/loading/loading_widget.dart';
import 'package:jarlenmodas/utils/form_utils/value_acessor/currency_value_acessor.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:intl/intl.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class DebitClientPageFrm extends StatefulWidget {
  const DebitClientPageFrm({super.key, this.cpfCliente});
  final String? cpfCliente;

  @override
  State<DebitClientPageFrm> createState() => _DebitClientPageFrmState();
}

class _DebitClientPageFrmState extends State<DebitClientPageFrm> {
  final TextEditingController cpfController = TextEditingController();
  Uint8List? _selectedDocument;

  late final ClientPageCubit clientCubit;
  late final DebitClientPageCubit debitCubit;

  late PlutoGridStateManager stateManager;
  late List<PlutoColumn> columns;

  late final FormGroup form;

  @override
  void initState() {
    super.initState();

    cpfController.text = widget.cpfCliente ?? '';
    form = FormGroup({
      'client': FormControl<ClientModel>(validators: [Validators.required]),
      'value': FormControl<double>(
        validators: [Validators.required, Validators.min(0.01)],
      ),
      'dueDate': FormControl<DateTime>(validators: [Validators.required]),
      'document': FormControl<Uint8List>(),
    });

    columns = [
      PlutoColumn(
        title: 'Valor',
        field: 'value',
        type: PlutoColumnType.currency(
          symbol: "R\$ ",
          format: "#,##0.00",
          locale: "pt_BR",
        ),
        footerRenderer: (rendererContext) {
          final total = rendererContext.stateManager.rows.fold<double>(
            0,
            (sum, row) => sum + (row.cells['value']?.value ?? 0.0),
          );
          // CORREÇÃO 1: Retorna o widget diretamente, sem PlutoGridTableFooter
          return Center(
            child: Text(
              'Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(total)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Data Vencimento',
        field: 'dueDate',
        type: PlutoColumnType.date(format: 'dd/MM/yyyy'),
      ),
      PlutoColumn(
        title: 'Comprovante',
        field: 'document',
        type: PlutoColumnType.text(),
        readOnly: true,
        renderer: (rendererContext) {
          final hasDocument = rendererContext.cell.value != null;
          return Text(hasDocument ? "Anexado" : "Nenhum");
        },
      ),
      PlutoColumn(
        title: 'Ações',
        field: 'actions',
        type: PlutoColumnType.text(),
        width: 120,
        enableEditingMode: false,
        renderer: (rendererContext) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: () {
                  _editDebit(rendererContext.row);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () {
                  _deleteDebit(rendererContext.row);
                },
              ),
            ],
          );
        },
      ),
    ];

    loadData(widget.cpfCliente);
  }

  void loadDebits(String cpf) {
    debitCubit.load(DebitClientFilter(cpfClient: cpf));
  }

  void loadClients() {
    clientCubit.load(ClientFilter());
  }

  void loadData(String? cpfClient) {
    clientCubit = ClientPageCubit(ClientService());
    debitCubit = DebitClientPageCubit(DebitClientService());
    loadClients();
    if (cpfClient != null && cpfClient.isNotEmpty) {
      loadDebits(cpfClient);
    }
  }

  Future<void> _pickDocument() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedDocument = bytes;
        form.control('document').value = bytes;
      });
    }
  }

  void _addExpenseToGrid() {
    if (!form.valid && cpfController.text.isEmpty) {
      form.markAllAsTouched();
      if (cpfController.text.isEmpty) {
        MessageHelper.showWarningMessage(
          context,
          'Por favor, informe o cliente primeiro.',
        );
        return;
      }
    }

    final newRow = PlutoRow(
      cells: {
        'value': PlutoCell(value: form.control('value').value),
        'dueDate': PlutoCell(value: form.control('dueDate').value),
        'document': PlutoCell(value: form.control('document').value),
        'actions': PlutoCell(value: ''),
      },
    );
    stateManager.appendRows([newRow]);
    form.reset();
    setState(() {
      _selectedDocument = null;
    });
    changeEnabledClientDropDown(false);
  }

  void changeEnabledClientDropDown(bool enabled) {
    setState(() {
      if (enabled) {
        form.control('client').markAsEnabled();
        cpfController.text = '';
      } else {
        final selectedClient = form.control('client').value as ClientModel?;
        cpfController.text = selectedClient?.cpfClient ?? '';
        form.control('client').markAsDisabled();
      }
    });
  }

  void _editDebit(PlutoRow row) {
    final dueDateValue = row.cells['dueDate']?.value;
    DateTime? dueDate;
    if (dueDateValue is DateTime) {
      dueDate = dueDateValue;
    } else if (dueDateValue is String) {
      dueDate = DateTime.tryParse(dueDateValue);
    }

    form.patchValue({
      'value': row.cells['value']?.value,
      'dueDate': dueDate,
      'document': row.cells['document']?.value,
    });
    setState(() {
      _selectedDocument = row.cells['document']?.value;
    });
  }

  void _deleteDebit(PlutoRow row) {
    stateManager.removeRows([row]);
    bool isClientSaved =
        widget.cpfCliente != null && widget.cpfCliente!.isNotEmpty;
    if (!isClientSaved && stateManager.rows.isEmpty) {
      changeEnabledClientDropDown(true);
    }
  }

  void _saveDebits() {
    if (stateManager.rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos uma despesa para salvar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // final List<DebitClientModel> debitsToSave = stateManager.rows.map((row) {
    //   return DebitClientModel(
    //     id: '',
    //     cpfClient: cpfController.text,
    //     value: row.cells['value']!.value,
    //     dueDate: DateFormat('yyyy-MM-dd').format(row.cells['dueDate']!.value),
    //     dataCreation: DateTime.now(),
    //     document: row.cells['document']!.value as Uint8List?,
    //   );
    // }).toList();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Débitos salvos com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isCpfReadOnly =
        widget.cpfCliente != null && widget.cpfCliente!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("Débitos do Cliente")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ReactiveForm(
              formGroup: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: BlocBuilder<ClientPageCubit, ClientPageState>(
                          bloc: clientCubit,
                          builder: (context, clientState) {
                            if (clientState.loading) {
                              return const LoadingWidget();
                            }

                            ClientModel? client = clientCubit.state.clients
                                .where(
                                  (element) =>
                                      element.cpfClient == widget.cpfCliente,
                                )
                                .firstOrNull;

                            return ReactiveFormField<ClientModel, ClientModel>(
                              formControlName: 'client',
                              validationMessages: {
                                ValidationMessage.required: (_) =>
                                    'O cliente é obrigatório.',
                              },
                              builder: (field) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropDownSearchWidget<ClientModel>(
                                      textFunction: (client) => client.name,
                                      initialValue: client ?? field.value,
                                      sourceList: clientCubit.state.clients,
                                      placeholder: 'Cliente',
                                      readOnly:
                                          isCpfReadOnly ||
                                          !field.control.enabled,
                                      onChanged: (value) {
                                        field.didChange(value);
                                        cpfController.text =
                                            value?.cpfClient ?? '';
                                        field.control.markAsTouched();
                                      },
                                    ),
                                    if (field.control.invalid &&
                                        field.control.touched)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          field.errorText ?? '',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ReactiveTextField<double>(
                    formControlName: 'value',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      CurrencyTextInputFormatter.simpleCurrency(
                        locale: 'pt_BR',
                        decimalDigits: 2,
                      ),
                    ],
                    valueAccessor: CurrencyValueAccessor(),
                    decoration: const InputDecoration(
                      labelText: 'Valor do Débito',
                    ),
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          'O valor é obrigatório.',
                      ValidationMessage.min: (_) =>
                          'O valor deve ser positivo.',
                    },
                  ),
                  const SizedBox(height: 12),
                  ReactiveDatePicker<DateTime>(
                    formControlName: 'dueDate',
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    builder: (context, picker, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReactiveTextField(
                            formControlName: 'dueDate',
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Data de Vencimento',
                              suffixIcon: IconButton(
                                onPressed: picker.showPicker,
                                icon: const Icon(Icons.calendar_today),
                              ),
                            ),
                            valueAccessor: DateTimeValueAccessor(
                              dateTimeFormat: DateFormat('dd/MM/yyyy'),
                            ),
                            validationMessages: {
                              ValidationMessage.required: (_) =>
                                  'A data de vencimento é obrigatória',
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickDocument,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Anexar Comprovante'),
                      ),
                      const SizedBox(width: 10),
                      if (_selectedDocument != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                      if (_selectedDocument != null) const SizedBox(width: 5),
                      if (_selectedDocument != null)
                        const Text("Comprovante selecionado"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addExpenseToGrid,
                      icon: const Icon(Icons.add),
                      label: const Text("Adicionar Despesa ao Grid"),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            Expanded(
              child: BlocBuilder<DebitClientPageCubit, DebitClientPageState>(
                bloc: debitCubit,
                builder: (context, state) {
                  if (state.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final rows = state.debitClients.map((d) {
                    return PlutoRow(
                      cells: {
                        'value': PlutoCell(value: d.value),
                        'dueDate': PlutoCell(
                          value: DateTime.tryParse(d.dueDate),
                        ),
                        'document': PlutoCell(value: d.document),
                        'actions': PlutoCell(value: ''),
                      },
                    );
                  }).toList();

                  return PlutoGrid(
                    columns: columns,
                    rows: rows,
                    onLoaded: (event) {
                      stateManager = event.stateManager;
                    },
                    configuration:
                        const PlutoGridConfiguration(), // sem rowColor
                    rowColorCallback: (PlutoRowColorContext rowColorContext) {
                      final dueDateValue =
                          rowColorContext.row.cells['dueDate']?.value;
                      DateTime? dueDate;
                      if (dueDateValue is DateTime) {
                        dueDate = dueDateValue;
                      } else if (dueDateValue is String) {
                        dueDate = DateTime.tryParse(dueDateValue);
                      }
                      if (dueDate != null &&
                          dueDate.isBefore(
                            DateTime.now().subtract(const Duration(days: 1)),
                          )) {
                        return Colors.red;
                      }
                      return Colors.transparent;
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _saveDebits,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Tudo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
