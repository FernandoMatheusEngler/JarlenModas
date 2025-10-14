import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarlenmodas/dto/client/debit_client_dto.dart';
import 'package:jarlenmodas/models/client/debit_client_model/debit_client_model.dart';
import 'package:jarlenmodas/services/clients/debit_clients_service/debit_client_service.dart';

class DebitClientPageFrmCubit extends Cubit<DebitClientPageFrmCubitState> {
  DebitClientService service = DebitClientService();
  DebitClientPageFrmCubit({required this.service})
    : super(DebitClientPageFrmCubitState(debitClients: []));

  Future<void> save(
    List<DebitClientDTO> debitClients,
    final void Function() onSaved,
  ) async {
    try {
      emit(DebitClientPageFrmCubitState(debitClients: [], loading: true));
      List<DebitClientModel> debitsToSave = [];

      for (DebitClientDTO debit in debitClients) {
        String? documentUrl;
        if (debit.documentoBytes != null && debit.documentoBytes is Uint8List) {
          documentUrl = await service.uploadDocumentAsWebP(
            imageBytes: debit.documentoBytes as Uint8List,
            cpfClient: debit.cpfClient,
          );
        }

        final debitToSave = DebitClientModel(
          cpfClient: debit.cpfClient,
          value: debit.value,
          dueDate: debit.dueDate,
          dataCreation: debit.dataCreation,
          documentUrl: documentUrl,
        );

        service.addDebitClient(debitToSave);
        debitsToSave.add(debitToSave);
      }

      emit(
        DebitClientPageFrmCubitState(
          debitClients: debitsToSave,
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
