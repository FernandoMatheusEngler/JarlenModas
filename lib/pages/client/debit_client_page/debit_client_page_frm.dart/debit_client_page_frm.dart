import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarlenmodas/cubits/client/client_cubit/client_cubit.dart';
import 'package:jarlenmodas/cubits/client/debit_client_cubit/debit_client_cubit.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:jarlenmodas/models/client/client_model/client_filter.dart';
import 'package:jarlenmodas/models/client/debit_client_model/debit_client_filter.dart';

class DebitClientPageFrm extends StatefulWidget {
  const DebitClientPageFrm({super.key, required this.cpfCliente});
  final String? cpfCliente;

  @override
  State<DebitClientPageFrm> createState() => _DebitClientPageFrmState();
}

class _DebitClientPageFrmState extends State<DebitClientPageFrm> {
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  late List<PlutoColumn> columns;
  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    cpfController.text = widget.cpfCliente ?? '';

    columns = [
      PlutoColumn(
        title: 'CPF',
        field: 'cpfClient',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
      PlutoColumn(
        title: 'Valor',
        field: 'value',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Data Vencimento',
        field: 'dueDate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Data Criação',
        field: 'dataCreation',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
      PlutoColumn(
        title: 'Documento',
        field: 'document',
        type: PlutoColumnType.text(),
      ),
    ];

    // Carregar cliente + despesas iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.cpfCliente != null && widget.cpfCliente!.isNotEmpty) {
        context.read<ClientPageCubit>().load(
          ClientFilter(cpfClient: widget.cpfCliente!),
        );
        context.read<DebitClientPageCubit>().load(
          DebitClientFilter(cpfClient: widget.cpfCliente!),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Despesas do Cliente")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CPF
            TextField(
              controller: cpfController,
              decoration: const InputDecoration(labelText: "CPF do Cliente"),
              onSubmitted: (cpf) {
                if (cpf.isNotEmpty) {
                  context.read<ClientPageCubit>().load(
                    ClientFilter(cpfClient: cpf),
                  );
                  context.read<DebitClientPageCubit>().load(
                    DebitClientFilter(cpfClient: cpf),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            // Nome do cliente via cubit
            BlocBuilder<ClientPageCubit, ClientPageState>(
              builder: (context, state) {
                if (state.loading) {
                  return const CircularProgressIndicator();
                }
                if (state.clients.isNotEmpty) {
                  nomeController.text = state.clients.first.name;
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
            const SizedBox(height: 16),

            // Grid de despesas
            Expanded(
              child: BlocBuilder<DebitClientPageCubit, DebitClientPageState>(
                builder: (context, state) {
                  if (state.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final rows = state.debitClients.map((d) {
                    return PlutoRow(
                      cells: {
                        'cpfClient': PlutoCell(value: d.cpfClient),
                        'value': PlutoCell(value: d.value),
                        'dueDate': PlutoCell(value: d.dueDate),
                        'dataCreation': PlutoCell(
                          value: d.dataCreation?.toString(),
                        ),
                        'document': PlutoCell(
                          value: d.document != null ? "Anexado" : "",
                        ),
                      },
                    );
                  }).toList();

                  return PlutoGrid(
                    columns: columns,
                    rows: rows,
                    onLoaded: (event) {
                      stateManager = event.stateManager;
                      // Estilizar linhas vencidas
                      // stateManager.setRowColorCallback((row) {
                      //   final dueDateStr = row.cells['dueDate']?.value;
                      //   if (dueDateStr != null && dueDateStr.isNotEmpty) {
                      //     final dueDate = DateTime.tryParse(dueDateStr);
                      //     if (dueDate != null &&
                      //         dueDate.isBefore(DateTime.now())) {
                      //       return Colors.red.withOpacity(0.3);
                      //     }
                      //   }
                      //   return Colors.transparent;
                      // });
                    },
                    configuration: const PlutoGridConfiguration(),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            // Botão para adicionar despesa
            ElevatedButton.icon(
              onPressed: () {
                final newRow = PlutoRow(
                  cells: {
                    'cpfClient': PlutoCell(value: cpfController.text),
                    'value': PlutoCell(value: 0.0),
                    'dueDate': PlutoCell(value: ''),
                    'dataCreation': PlutoCell(value: DateTime.now().toString()),
                    'document': PlutoCell(value: ''),
                  },
                );
                stateManager.appendRows([newRow]);
              },
              icon: const Icon(Icons.add),
              label: const Text("Adicionar Despesa"),
            ),
          ],
        ),
      ),
    );
  }
}
