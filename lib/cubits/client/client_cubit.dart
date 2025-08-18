import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarlenmodas/models/client/client_filter.dart';
import 'package:jarlenmodas/models/client/client_model.dart';
import 'package:jarlenmodas/services/client/client_service.dart';

class ClientPageCubit extends Cubit<ClientState> {
  final ClientService service;
  ClientPageCubit(this.service) : super(ClientState(clients: []));

  Future<void> load(ClientFilter filter) async {
    try {
      emit(ClientState(clients: [], loading: true));
      List<ClientModel> clients = await service.getClients(filter);
      emit(ClientState(clients: clients, loaded: true));
    } catch (ex) {
      emit(
        ClientState(
          clients: state.clients,
          loaded: false,
          error: ex.toString(),
        ),
      );
    }
  }

  Future<void> delete(ClientModel client) async {
    try {
      await service.deleteClient(client.cpfClient);
      emit(ClientState(clients: state.clients, loaded: true));
    } catch (ex) {
      emit(
        ClientState(
          clients: state.clients,
          loaded: false,
          error: ex.toString(),
        ),
      );
    }
  }
}

class ClientState {
  final List<ClientModel> clients;
  bool loading;
  bool loaded;
  String error;

  ClientState({
    required this.clients,
    this.loading = false,
    this.loaded = false,
    this.error = '',
  });
}
