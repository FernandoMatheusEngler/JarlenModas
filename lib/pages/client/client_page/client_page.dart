import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarlenmodas/components/buttons/refresh_button_widget.dart';
import 'package:jarlenmodas/core/error_helper.dart';
import 'package:jarlenmodas/core/message_helper.dart';
import 'package:jarlenmodas/cubits/client/client_cubit/client_cubit.dart';
import 'package:jarlenmodas/models/client/client_model/client_filter.dart';
import 'package:jarlenmodas/models/client/client_model/client_model.dart';
import 'package:jarlenmodas/pages/client/client_page/client_page_frm/client_page_frm.dart';
import 'package:jarlenmodas/services/clients/client_service/client_service.dart';
import 'package:jarlenmodas/components/loading/loading_widget.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ClientPage extends StatelessWidget {
  const ClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientPageCubit(ClientService()),
      child: BlocListener<ClientPageCubit, ClientPageState>(
        listener: (context, state) {
          if (state.error.isNotEmpty) {
            ErrorHelper.showMessage(context, state.error);
          }
        },
        child: const ClientPageContent(),
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
  late final ClientPageCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<ClientPageCubit>();
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
                      cpfClient: rendererContext.row.cells['cpfClient']!.value
                          .toString(),
                      name: rendererContext.row.cells['nome']!.value,
                      phone: rendererContext.row.cells['telefone']!.value,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () {
                  _deleteClient(
                    rendererContext.row.cells['cpfClient']!.value as String,
                  );
                },
              ),
            ],
          );
        },
      ),
      PlutoColumn(
        title: 'CPF Cliente',
        field: 'cpfClient',
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
        title: 'Telefone',
        field: 'telefone',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
    ];
    cubit.load(ClientFilter());
  }

  void _openClientForm(BuildContext context, {ClientModel? client}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientPageFrm(onSaved: onSaved, client: client),
      ),
    );
  }

  void _deleteClient(String cpfClient) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Deseja realmente excluir este cliente?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await cubit.delete(cpfClient);
      MessageHelper.showSuccessMessage(
        // ignore: use_build_context_synchronously
        context,
        'Cliente excluído com sucesso!',
      );
      refreshList();
    }
  }

  void refreshList() {
    cubit.load(ClientFilter());
  }

  void onSaved(String cpfClient) {
    Navigator.pop(context);
    MessageHelper.showSuccessMessage(context, 'Cliente salvo com sucesso!');
    refreshList();
  }

  List<PlutoRow> clientsToRows(List<ClientModel> clients) {
    return clients
        .map(
          (client) => PlutoRow(
            cells: {
              'acoes': PlutoCell(value: ''),
              'cpfClient': PlutoCell(value: client.cpfClient),
              'nome': PlutoCell(value: client.name),
              'telefone': PlutoCell(value: client.phone),
            },
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 10),
            RefreshButtonWidget(onPressed: refreshList),
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
        BlocBuilder<ClientPageCubit, ClientPageState>(
          bloc: cubit,
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: LoadingWidget());
            }
            return Expanded(
              child: PlutoGrid(
                columns: columns,
                rows: clientsToRows(state.clients),
                onLoaded: (event) {
                  stateManager = event.stateManager;
                  stateManager.setShowColumnFilter(true);
                },
                onChanged: (event) {
                  debugPrint(
                    'Alteração na célula: ${event.row.key}, valor: ${event.value}',
                  );
                },
                configuration: const PlutoGridConfiguration(),
              ),
            );
          },
        ),
      ],
    );
  }
}
