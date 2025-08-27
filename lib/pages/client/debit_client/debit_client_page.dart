import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarlenmodas/core/error_helper.dart';
import 'package:jarlenmodas/cubits/client/debit_client_cubit/debit_client_cubit.dart';
import 'package:jarlenmodas/services/clients/debit_clients_service/debit_client_service.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                // _openClientForm(context, client: null);
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
