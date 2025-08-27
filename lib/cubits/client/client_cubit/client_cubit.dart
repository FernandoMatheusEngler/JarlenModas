import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarlenmodas/models/client/client_model/client_filter.dart';
import 'package:jarlenmodas/models/client/client_model/client_model.dart';
import 'package:jarlenmodas/services/clients/client_service/client_service.dart';

class ClientPageCubit extends Cubit<ClientPageState> {
  final ClientService service;
  ClientPageCubit(this.service) : super(ClientPageState(clients: []));

  Future<void> load(ClientFilter filter) async {
    try {
      emit(ClientPageState(clients: [], loading: true));
      List<ClientModel> clients = await service.getClients(filter);
      emit(ClientPageState(clients: clients, loaded: true, loading: false));
    } catch (ex) {
      emit(
        ClientPageState(
          clients: state.clients,
          loaded: false,
          loading: false,
          error: ex.toString(),
        ),
      );
    }
  }

  Future<void> delete(String cpfClient) async {
    try {
      await service.deleteClient(cpfClient);
      emit(ClientPageState(clients: state.clients, loaded: true));
    } catch (ex) {
      emit(
        ClientPageState(
          clients: state.clients,
          loaded: false,
          error: ex.toString(),
        ),
      );
    }
  }
}

class ClientPageState {
  final List<ClientModel> clients;
  bool loading;
  bool loaded;
  String error;

  ClientPageState({
    required this.clients,
    this.loading = false,
    this.loaded = false,
    this.error = '',
  });
}
