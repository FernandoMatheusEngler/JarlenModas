import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarlenmodas/models/client/debit_client_model/debit_client_model.dart';
import 'package:jarlenmodas/services/clients/debit_clients_service/debit_client_service.dart';

class DebitClientPageCubit extends Cubit<DebitClientPageState> {
  final DebitClientService service;
  DebitClientPageCubit(this.service)
    : super(DebitClientPageState(debitClients: []));
}

class DebitClientPageState {
  final List<DebitClientModel> debitClients;
  bool loading;
  bool loaded;
  String error;
  DebitClientPageState({
    required this.debitClients,
    this.loading = false,
    this.loaded = false,
    this.error = '',
  });
}
