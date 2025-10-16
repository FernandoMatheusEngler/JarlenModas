import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarlenmodas/components/buttons/refresh_button_widget.dart';
import 'package:jarlenmodas/components/drop_down/drop_down_search_widget.dart';
import 'package:jarlenmodas/components/buttons/filter_dialog_widget.dart';
import 'package:jarlenmodas/core/error_helper.dart';
import 'package:jarlenmodas/core/message_helper.dart';
import 'package:jarlenmodas/cubits/client/client_cubit/client_cubit.dart';
import 'package:jarlenmodas/cubits/client/debit_client_cubit/debit_client_cubit.dart';
import 'package:jarlenmodas/models/client/client_model/client_filter.dart';
import 'package:jarlenmodas/models/client/client_model/client_model.dart';
import 'package:jarlenmodas/models/client/debit_client_model/debit_client_filter.dart';
import 'package:jarlenmodas/models/client/debit_client_model/debit_client_model.dart';
import 'package:jarlenmodas/pages/client/debit_client_page/debit_client_page_frm.dart/debit_client_page_frm.dart';
import 'package:jarlenmodas/services/clients/client_service/client_service.dart';
import 'package:jarlenmodas/services/clients/debit_clients_service/debit_client_service.dart';
import 'package:jarlenmodas/components/loading/loading_widget.dart';
import 'package:pluto_grid/pluto_grid.dart';

class DebitClientPage extends StatelessWidget {
  const DebitClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DebitClientPageCubit(DebitClientService()),
      child: BlocListener<DebitClientPageCubit, DebitClientPageState>(
        listener: (context, state) {
          if (state.error.isNotEmpty) {
            ErrorHelper.showMessage(context, state.error);
          }
        },
        child: const DebitClientPageContent(),
      ),
    );
  }
}

class DebitClientPageContent extends StatefulWidget {
  const DebitClientPageContent({super.key});

  @override
  State<DebitClientPageContent> createState() => _DebitClientPageContentState();
}

class _DebitClientPageContentState extends State<DebitClientPageContent> {
  late final List<PlutoColumn> columns;
  late final List<PlutoRow> rows;
  late PlutoGridStateManager stateManager;
  late final DebitClientPageCubit cubit;
  late final ClientPageCubit clientCubit;
  late final DebitClientFilter filter;
  @override
  void initState() {
    super.initState();
    filter = DebitClientFilter();
    cubit = context.read<DebitClientPageCubit>();
    clientCubit = ClientPageCubit(ClientService());
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
                  _openDebitsClientFrm(
                    rendererContext.row.cells['cpfClient']!.value,
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
        title: 'Nome Cliente',
        field: 'nome',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
      PlutoColumn(
        title: 'Valor Total Débito',
        field: 'valorTotalDebito',
        type: PlutoColumnType.number(
          applyFormatOnInit: true,
          format: '#,##0.00',
        ),
        readOnly: true,
      ),
    ];
    refreshList();
  }

  Future<List<PlutoRow>> debitsToRows(List<DebitClientModel> debits) async {
    Map<String, DebitClientModel> debitsByCpf = {};

    for (final DebitClientModel debit in debits) {
      if (debitsByCpf.containsKey(debit.cpfClient)) {
        final DebitClientModel existingDebit = debitsByCpf[debit.cpfClient]!;
        existingDebit.value += debit.value;
        debitsByCpf[debit.cpfClient] = existingDebit;
      } else {
        debitsByCpf[debit.cpfClient] = debit;
      }
    }

    return Future.wait(
      debitsByCpf.values.toList().map((debit) async {
        await clientCubit.load(ClientFilter(cpfClient: debit.cpfClient.trim()));
        ClientModel? client = clientCubit.state.clients
            .where((element) => element.cpfClient == debit.cpfClient)
            .firstOrNull;
        return PlutoRow(
          cells: {
            'acoes': PlutoCell(value: ''),
            'cpfClient': PlutoCell(value: debit.cpfClient),
            'nome': PlutoCell(value: client?.name ?? ''),
            'valorTotalDebito': PlutoCell(value: debit.value),
          },
        );
      }),
    );
  }

  void _openDebitsClientFrm(String? cpfCliente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DebitClientPageFrm(cpfCliente: cpfCliente, onSaved: onSaved),
      ),
    );
  }

  Future _openFilterDialog(BuildContext context) async {
    clientCubit.load(ClientFilter());
    bool? confirm = await showDialog<bool?>(
      context: context,
      builder: (context) {
        return FilterDialogWidget(
          child: Column(
            children: [
              BlocBuilder<ClientPageCubit, ClientPageState>(
                bloc: clientCubit,
                builder: (context, clientState) {
                  if (clientState.loading) {
                    return const LoadingWidget();
                  }
                  ClientModel? client = clientCubit.state.clients
                      .where((element) => element.cpfClient == filter.cpfClient)
                      .firstOrNull;
                  return DropDownSearchWidget<ClientModel>(
                    textFunction: (client) => client.name,
                    initialValue: client,
                    sourceList: clientCubit.state.clients,
                    onChanged: (value) => filter.cpfClient = value?.cpfClient,
                    placeholder: 'Cliente',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
    if (confirm != true) return;
    cubit.load(filter);
  }

  void onSaved() {
    Navigator.pop(context);
    MessageHelper.showSuccessMessage(context, 'Débitos salvos com sucesso!');
    refreshList();
  }

  void refreshList() {
    cubit.load(filter);
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
              onPressed: () async => await _openFilterDialog(context),
              icon: const Icon(Icons.search),
              label: const Text('Filtrar'),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                _openDebitsClientFrm(null);
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        BlocBuilder<DebitClientPageCubit, DebitClientPageState>(
          bloc: cubit,
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: LoadingWidget());
            }
            return Expanded(
              child: FutureBuilder<List<PlutoRow>>(
                future: debitsToRows(state.debitClients),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LoadingWidget());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar dados'));
                  }
                  final rows = snapshot.data ?? [];
                  return PlutoGrid(
                    columns: columns,
                    rows: rows,
                    onLoaded: (event) {
                      stateManager = event.stateManager;
                      stateManager.setShowColumnFilter(true);
                    },
                    configuration: const PlutoGridConfiguration(),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
