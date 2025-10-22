import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jarlenmodas/components/drop_down/drop_down_search_widget.dart';
import 'package:jarlenmodas/cubits/client/client_cubit/client_cubit.dart';
import 'package:jarlenmodas/cubits/client/debit_client_cubit/debit_client_cubit.dart';
import 'package:jarlenmodas/cubits/client/debit_client_cubit/debit_client_cubit_frm/debit_client_cubit_frm.dart';
import 'package:jarlenmodas/dto/client/debit_client_dto.dart';
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
  const DebitClientPageFrm({super.key, this.cpfCliente, required this.onSaved});
  final String? cpfCliente;
  final void Function() onSaved;

  @override
  State<DebitClientPageFrm> createState() => _DebitClientPageFrmState();
}

class _DebitClientPageFrmState extends State<DebitClientPageFrm> {
  final TextEditingController cpfController = TextEditingController();
  Uint8List? _selectedDocument;
  int? _idDebitSelected;
  bool hasRows = false;

  late final ClientPageCubit clientCubit;
  late final DebitClientPageCubit debitCubit;
  late final DebitClientPageFrmCubit cubit;

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
      'paid': FormControl<bool>(value: false),
    });

    columns = createColumnsGrid();
    loadData(widget.cpfCliente);
  }

  List<PlutoColumn> createColumnsGrid() {
    return [
      PlutoColumn(
        title: '',
        field: 'actions',
        type: PlutoColumnType.text(),
        width: 160,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final row = rendererContext.row;
          final isSaved = row.cells['saved']?.value == true;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: () {
                  _editDebit(row);
                },
              ),
              // IconButton(
              //   icon: Icon(
              //     isPaid ? Icons.check_box : Icons.check_box_outline_blank,
              //     color: isPaid ? Colors.green : Colors.grey,
              //     size: 20,
              //   ),
              //   onPressed: () {
              //     // toggle paid status in the row
              //     row.cells['paid']?.value =
              //         !(row.cells['paid']?.value == true);
              //     stateManager.notifyListeners();
              //   },
              // ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                // disable delete if this row corresponds to an already-saved debit
                onPressed: isSaved
                    ? null
                    : () {
                        _deleteDebit(row);
                      },
              ),
            ],
          );
        },
      ),
      PlutoColumn(
        title: 'Valor',
        field: 'value',
        enableEditingMode: false,
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
        enableEditingMode: false,
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
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Quitado',
        field: 'paid',
        type: PlutoColumnType.text(),
        readOnly: false,
        renderer: (rendererContext) {
          final isPaid = rendererContext.cell.value == true;
          final isSaved = rendererContext.row.cells['saved']?.value == true;
          return Checkbox(
            value: isPaid,
            onChanged: isSaved
                ? null
                : (value) {
                    rendererContext.row.cells['paid']?.value = value ?? false;
                    rendererContext.stateManager.notifyListeners();
                  },
          );
        },
        enableEditingMode: false,
      ),
    ];
  }

  DateTime? _parseDateValue(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      // Try ISO format first
      final iso = DateTime.tryParse(value);
      if (iso != null) return iso;
      // Try dd/MM/yyyy
      try {
        return DateFormat('dd/MM/yyyy').parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
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
    cubit = DebitClientPageFrmCubit(service: DebitClientService());

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
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    final existingRow = stateManager.rows.firstWhere(
      (row) => row.cells['rowIndex']?.value == _idDebitSelected,
      orElse: () => PlutoRow(cells: {}),
    );

    if (existingRow.cells.isNotEmpty) {
      updateDataDebitClientGrid(existingRow);
      return;
    }

    final newRow = PlutoRow(
      cells: {
        'rowIndex': PlutoCell(value: stateManager.rows.length + 1),
        'value': PlutoCell(value: form.control('value').value),
        'dueDate': PlutoCell(value: form.control('dueDate').value),
        'document': PlutoCell(value: form.control('document').value),
        'paid': PlutoCell(value: form.control('paid').value ?? false),
        'saved': PlutoCell(value: false),
        'actions': PlutoCell(value: ''),
      },
    );

    stateManager.appendRows([newRow]);
    resetFormAfterChange();
    changeEnabledClientDropDown(false);
  }

  void updateDataDebitClientGrid(PlutoRow existingRow) {
    final DateTime? dueDate = form.control('dueDate').value;
    existingRow.cells['value']?.value = form.control('value').value;
    existingRow.cells['dueDate']?.value = dueDate;
    existingRow.cells['paid']?.value = form.control('paid').value ?? false;
    existingRow.cells['document']?.value = form.control('document').value;
    stateManager.notifyListeners();
    resetFormAfterChange();
  }

  void resetFormAfterChange() {
    form.control('value').reset();
    form.control('dueDate').reset();
    form.control('document').reset();
    setState(() {
      _selectedDocument = null;
      _idDebitSelected = null;
    });
  }

  ClientModel? _clientValueBeforeDisable;
  void changeEnabledClientDropDown(bool enabled) {
    final clientControl = form.control('client');

    if (enabled) {
      if (_clientValueBeforeDisable != null) {
        clientControl.markAsEnabled();
        clientControl.markAsTouched();
        clientControl.updateValue(_clientValueBeforeDisable);
        _clientValueBeforeDisable = null;
      }
    } else {
      _clientValueBeforeDisable = clientControl.value;
      clientControl.markAsDisabled();
    }
  }

  void _editDebit(PlutoRow row) {
    final dueDateValue = row.cells['dueDate']?.value;
    DateTime? parsedDate;

    if (dueDateValue is DateTime) {
      parsedDate = dueDateValue;
    } else if (dueDateValue is String && dueDateValue.isNotEmpty) {
      parsedDate = DateFormat('dd/MM/yyyy').parse(dueDateValue);
    }

    final documentValue = row.cells['document']?.value;
    Uint8List? documentBytes;
    final paidValue = row.cells['paid']?.value == true;

    if (documentValue is Uint8List) {
      documentBytes = documentValue;
    }

    form.patchValue({
      'value': row.cells['value']?.value,
      'dueDate': parsedDate,
      'document': documentBytes,
      'paid': paidValue,
    });

    setState(() {
      _selectedDocument = documentBytes;
      _idDebitSelected = row.cells['rowIndex']?.value;
    });
  }

  void _deleteDebit(PlutoRow row) {
    stateManager.removeRows([row]);
    bool isClientSaved =
        widget.cpfCliente != null && widget.cpfCliente!.isNotEmpty;
    if (!isClientSaved && stateManager.rows.isEmpty) {
      changeEnabledClientDropDown(true);
    }

    bool hasDebitSelect = _idDebitSelected != null;
    if (hasDebitSelect) {
      resetFormAfterChange();
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

    final List<DebitClientDTO> debitsToSave = stateManager.rows.map((row) {
      final docCell = row.cells['document']?.value;
      Uint8List? bytes;
      String? url;
      if (docCell is Uint8List) {
        bytes = docCell;
      } else if (docCell is String && docCell.isNotEmpty) {
        url = docCell;
      }

      return DebitClientDTO(
        cpfClient: cpfController.text,
        value: row.cells['value']!.value,
        dueDate: row.cells['dueDate']!.value is DateTime
            ? (row.cells['dueDate']!.value as DateTime).toIso8601String()
            : row.cells['dueDate']!.value?.toString() ?? '',
        dataCreation: DateTime.now(),
        documentBytes: bytes,
        documentUrl: url,
        paid: row.cells['paid']?.value == true,
      );
    }).toList();

    cubit.save(debitsToSave, widget.onSaved);
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
                                // If the caller passed a CPF and we found the client,
                                // ensure the form control reflects it so validators pass.
                                if (client != null && field.value == null) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    field.didChange(client);
                                    if (widget.cpfCliente != null &&
                                        widget.cpfCliente!.isNotEmpty) {
                                      field.control.markAsDisabled();
                                    }
                                  });
                                }

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
                      const SizedBox(width: 20),
                      // Use a compact inline checkbox + label instead of CheckboxListTile
                      // to avoid infinite width issues inside a Row.
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ReactiveCheckbox(formControlName: 'paid'),
                          const SizedBox(width: 6),
                          const Text('Quitado'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addExpenseToGrid,
                      icon: const Icon(Icons.add),
                      label: const Text("Adicionar Despesa"),
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
                  int contador = 0;
                  final rows = state.debitClients.map((debit) {
                    return PlutoRow(
                      cells: {
                        'rowIndex': PlutoCell(value: contador++),
                        'value': PlutoCell(value: debit.value),
                        'dueDate': PlutoCell(
                          value: _parseDateValue(debit.dueDate),
                        ),
                        'document': PlutoCell(value: debit.documentUrl),
                        'paid': PlutoCell(value: debit.paid),
                        'saved': PlutoCell(value: true),
                        'actions': PlutoCell(value: ''),
                      },
                    );
                  }).toList();

                  return PlutoGrid(
                    columns: columns,
                    rows: rows,
                    onLoaded: (event) {
                      stateManager = event.stateManager;

                      setState(() {
                        hasRows = stateManager.rows.isNotEmpty;
                      });

                      stateManager.addListener(() {
                        setState(() {
                          hasRows = stateManager.rows.isNotEmpty;
                        });
                      });
                    },
                    configuration:
                        const PlutoGridConfiguration(), // sem rowColor
                    rowColorCallback: (PlutoRowColorContext rowColorContext) {
                      final dueDateValue =
                          rowColorContext.row.cells['dueDate']?.value;
                      final isPaid =
                          rowColorContext.row.cells['paid']?.value == true;
                      DateTime? dueDate;
                      if (dueDateValue is DateTime) {
                        dueDate = dueDateValue;
                      } else if (dueDateValue is String) {
                        dueDate = DateTime.tryParse(dueDateValue);
                      }

                      if (isPaid) {
                        // ignore: deprecated_member_use
                        return Colors.green.withOpacity(0.15);
                      }

                      if (dueDate != null &&
                          dueDate.isBefore(
                            DateTime.now().subtract(const Duration(days: 1)),
                          )) {
                        // ignore: deprecated_member_use
                        return Colors.red.withOpacity(0.15);
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
                  onPressed: form.valid || hasRows ? _saveDebits : null,
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
