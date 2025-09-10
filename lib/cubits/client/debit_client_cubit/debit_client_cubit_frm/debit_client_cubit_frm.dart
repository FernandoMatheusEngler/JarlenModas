import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarlenmodas/models/client/debit_client_model/debit_client_model.dart';
import 'package:jarlenmodas/services/clients/debit_clients_service/debit_client_service.dart';

class DebitClientPageFrmCubit extends Cubit<DebitClientPageFrmCubitState> {
  DebitClientService service = DebitClientService();
  DebitClientPageFrmCubit({required this.service})
    : super(DebitClientPageFrmCubitState(debitClients: []));

  void save(
    List<DebitClientModel> debitClients,
    final void Function() onSaved,
  ) {
    try {
      emit(DebitClientPageFrmCubitState(debitClients: [], loading: true));

      for (var debitClient in debitClients) {
        service.addDebitClient(debitClient);
      }
      emit(
        DebitClientPageFrmCubitState(
          debitClients: debitClients,
          loading: false,
          saved: true,
          message: 'Débitos salvos com sucesso!',
        ),
      );
      onSaved();
    } on Exception catch (ex) {
      emit(
        DebitClientPageFrmCubitState(debitClients: [], error: ex.toString()),
      );
    }
  }
}

class DebitClientPageFrmCubitState {
  final String error;
  final bool saved;
  final bool loading;
  final String message;

  DebitClientPageFrmCubitState({
    required List<DebitClientModel> debitClients,
    this.error = '',
    this.loading = false,
    this.saved = false,
    this.message = '',
  });
}
