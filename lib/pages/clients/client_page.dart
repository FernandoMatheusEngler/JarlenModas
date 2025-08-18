import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarlenmodas/core/error_helper.dart';
import 'package:jarlenmodas/cubits/client/client_cubit.dart';
import 'package:jarlenmodas/models/client/client_model.dart';
import 'package:jarlenmodas/pages/clients/client_page_frm/client_page_frm.dart';
import 'package:jarlenmodas/services/client/client_service.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:jarlenmodas/widgets/layout_controller/layout_widget.dart';

class ClientScreen extends StatelessWidget {
  const ClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientPageCubit(ClientService()),
      child: BlocListener<ClientPageCubit, ClientState>(
        listener: (context, state) {
          if (state.error.isNotEmpty) {
            ErrorHelper.showMessage(context, state.error, isError: true);
          }
        },
        child: LayoutWidget(content: const ClientPageContent()),
      ),
    );
  }
}

class ClientPageContent extends StatefulWidget {
  const ClientPageContent({super.key});

  @override
  State<ClientPageContent> createState() => _ClientPageContentState();
}

class _ClientPageContentState extends State<ClientPageContent> {
  late final List<PlutoColumn> columns;
  late final List<PlutoRow> rows;
  late PlutoGridStateManager stateManager;

  final ClientPageCubit cubit = ClientPageCubit(ClientService());

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: '',
        field: 'acoes',
        type: PlutoColumnType.text(),
        width: 120,
        renderer: (rendererContext) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: () {
                  _openClientForm(
                    context,
                    client: ClientModel(
                      cpfClient: rendererContext.row.cells['cpfCliente']!.value
                          .toString(),
                      name: rendererContext.row.cells['nome']!.value,
                      email: rendererContext.row.cells['email']!.value,
                      phone: rendererContext.row.cells['telefone']!.value,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () {
                  _deleteClient(
                    rendererContext.row.cells['cpfCliente']!.value as int,
                  );
                },
              ),
            ],
          );
        },
      ),
      PlutoColumn(
        title: 'CPF Cliente',
        field: 'cpfCliente',
        type: PlutoColumnType.text(),
        width: 120,
        readOnly: true,
      ),
      PlutoColumn(
        title: 'Nome',
        field: 'nome',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
      PlutoColumn(
        title: 'E-mail',
        field: 'email',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
      PlutoColumn(
        title: 'Telefone',
        field: 'telefone',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
    ];

    rows = [
      PlutoRow(
        cells: {
          'acoes': PlutoCell(value: ''),
          'cpfCliente': PlutoCell(value: 1),
          'nome': PlutoCell(value: 'Cliente A'),
          'email': PlutoCell(value: 'clientea@example.com'),
          'telefone': PlutoCell(value: '(11) 91234-5678'),
          'status': PlutoCell(value: 'Ativo'),
        },
      ),
      PlutoRow(
        cells: {
          'acoes': PlutoCell(value: ''),
          'cpfCliente': PlutoCell(value: 2),
          'nome': PlutoCell(value: 'Cliente B'),
          'email': PlutoCell(value: 'clienteb@example.com'),
          'telefone': PlutoCell(value: '(11) 91234-5678'),
          'status': PlutoCell(value: 'Inativo'),
        },
      ),
    ];
  }

  void _openClientForm(BuildContext context, {ClientModel? client}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientPageFrm(onSaved: onSaved, client: client),
      ),
    );
  }

  void _deleteClient(int cod) {
    setState(() {
      rows.removeWhere((row) => row.cells['cpfCliente']!.value == cod);
    });
  }

  void _refreshList() {
    debugPrint('Atualizando a lista de clientes...');
    // Chame sua API ou fonte de dados real aqui.
  }

  void onSaved(String cpfCliente) {
    _refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _refreshList,
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                _openClientForm(context, client: null);
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: PlutoGrid(
            columns: columns,
            rows: rows,
            onLoaded: (event) {
              stateManager = event.stateManager;
              stateManager.setShowColumnFilter(
                true,
              ); // ativa filtros por coluna
            },
            onChanged: (event) {
              debugPrint(
                'Alteração na célula: ${event.row.key}, valor: ${event.value}',
              );
            },
            configuration: const PlutoGridConfiguration(),
          ),
        ),
      ],
    );
  }
}
