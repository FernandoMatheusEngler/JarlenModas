import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jarlenmodas/cubits/client/client_cubit/client_cubit.dart';
import 'package:jarlenmodas/cubits/client/debit_client_cubit/debit_client_cubit.dart';
import 'package:jarlenmodas/models/client/client_model/client_filter.dart';
import 'package:jarlenmodas/models/client/debit_client_model/debit_client_filter.dart';
import 'package:jarlenmodas/models/client/debit_client_model/debit_client_model.dart'; // Verifique se este import está correto
import 'package:jarlenmodas/services/clients/client_service/client_service.dart';
import 'package:jarlenmodas/services/clients/debit_clients_service/debit_client_service.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:intl/intl.dart';

class DebitClientPageFrm extends StatefulWidget {
  const DebitClientPageFrm({super.key, this.cpfCliente});
  final String? cpfCliente;

  @override
  State<DebitClientPageFrm> createState() => _DebitClientPageFrmState();
}

class _DebitClientPageFrmState extends State<DebitClientPageFrm> {
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  late final ClientPageCubit clientCubit;
  late final DebitClientPageCubit debitCubit;
  late List<PlutoColumn> columns;
  late PlutoGridStateManager stateManager;

  late final FormGroup form;
  Uint8List? _selectedDocument;

  @override
  void initState() {
    super.initState();
    cpfController.text = widget.cpfCliente ?? '';
    clientCubit = ClientPageCubit(ClientService());
    debitCubit = DebitClientPageCubit(DebitClientService());

    form = FormGroup({
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
        title: 'Documento',
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

    if (widget.cpfCliente != null && widget.cpfCliente!.isNotEmpty) {
      loadData(widget.cpfCliente!);
    }
  }

  void loadData(String cpf) {
    clientCubit.load(ClientFilter(cpfClient: cpf));
    debitCubit.load(DebitClientFilter(cpfClient: cpf));
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
    if (form.valid && cpfController.text.isNotEmpty) {
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
    } else {
      form.markAllAsTouched();
      if (cpfController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, informe o CPF do cliente primeiro.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _editDebit(PlutoRow row) {
    form.patchValue({
      'value': row.cells['value']?.value,
      'dueDate': row.cells['dueDate']?.value,
      'document': row.cells['document']?.value,
    });
    setState(() {
      _selectedDocument = row.cells['document']?.value;
    });
    stateManager.removeRows([row]);
  }

  void _deleteDebit(PlutoRow row) {
    stateManager.removeRows([row]);
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

    final List<DebitClientModel> debitsToSave = stateManager.rows.map((row) {
      return DebitClientModel(
        id: '',
        cpfClient: cpfController.text,
        value: row.cells['value']!.value,
        dueDate: DateFormat('yyyy-MM-dd').format(row.cells['dueDate']!.value),
        dataCreation: DateTime.now(),
        document: row.cells['document']!.value as Uint8List?,
      );
    }).toList();

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: cpfController,
                    decoration: const InputDecoration(
                      labelText: "CPF do Cliente",
                    ),
                    readOnly: isCpfReadOnly,
                    onSubmitted: (cpf) {
                      if (cpf.isNotEmpty) {
                        loadData(cpf);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: BlocBuilder<ClientPageCubit, ClientPageState>(
                    bloc: clientCubit,
                    builder: (context, state) {
                      if (state.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.clients.isNotEmpty) {
                        nomeController.text = state.clients.first.name;
                      } else {
                        nomeController.text = '';
                      }
                      return TextField(
                        controller: nomeController,
                        decoration: const InputDecoration(
                          labelText: "Nome do Cliente",
                        ),
                        readOnly: true,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ReactiveForm(
              formGroup: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReactiveTextField<double>(
                    formControlName: 'value',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Valor da Despesa',
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
                          ),
                          // ReactiveErrorMessages<DateTime>(
                          //   formControlName: 'dueDate',
                          //   validationMessages: {
                          //     ValidationMessage.required: (_) =>
                          //         'A data de vencimento é obrigatória',
                          //     ValidationMessage.min: (_) => 'Data inválida',
                          //     ValidationMessage.max: (_) =>
                          //         'Data fora do intervalo permitido',
                          //   },
                          // ),
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
                        label: const Text('Anexar Nota'),
                      ),
                      const SizedBox(width: 10),
                      if (_selectedDocument != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                      if (_selectedDocument != null) const SizedBox(width: 5),
                      if (_selectedDocument != null)
                        const Text("Documento selecionado"),
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
                      final dueDate =
                          rowColorContext.row.cells['dueDate']?.value
                              as DateTime?;
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
