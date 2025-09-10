import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarlenmodas/models/client/client_model/client_model.dart';
import 'package:jarlenmodas/services/clients/client_service/client_service.dart';

class ClientPageFrmCubit extends Cubit<ClientPageFrmState> {
  final ClientService service;
  final ClientModel? clientModel;
  ClientPageFrmCubit({required this.service, required this.clientModel})
    : super(ClientPageFrmState(client: clientModel));

  void save(ClientModel client, final void Function(String) onSaved) async {
    try {
      ClientModel clientSaved = await service.addClient(client);
      emit(
        ClientPageFrmState(
          message: 'Cliente salvo com sucesso!',
          client: clientSaved,
        ),
      );
      onSaved(clientSaved.cpfClient);
    } on Exception catch (ex) {
      emit(ClientPageFrmState(error: ex.toString(), client: client));
    }
  }
}

class ClientPageFrmState {
  final String error;
  final String message;
  final ClientModel? client;

  ClientPageFrmState({
    required this.client,
    this.error = '',
    this.message = '',
  });
}
