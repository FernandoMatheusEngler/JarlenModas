import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarlenmodas/models/client/client_filter.dart';
import 'package:jarlenmodas/models/client/client_model.dart';
import 'package:jarlenmodas/services/client/client_service.dart';

class ClientCubit extends Cubit<ClientState> {
  ClientCubit(super.initialState);

  Future<void> load(ClientFilter filter) async {
    emit(ClientState(clients: [], loading: true));
    List<ClientModel> clients = await ClientService().getClients(filter);
    emit(ClientState(clients: clients, loaded: true));
  }
}

class ClientState {
  final List<ClientModel> clients;
  bool loading;
  bool loaded;

  ClientState({
    required this.clients,
    this.loading = false,
    this.loaded = false,
  });
}
