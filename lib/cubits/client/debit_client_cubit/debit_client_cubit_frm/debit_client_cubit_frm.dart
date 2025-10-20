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
      List<String?> uploadedUrls = List<String?>.filled(
        debitClients.length,
        null,
      );

      for (int i = 0; i < debitClients.length; i++) {
        final debit = debitClients[i];
        if (debit.documentBytes != null && debit.documentBytes is Uint8List) {
          final url = await service.uploadDocumentAsWebP(
            imageBytes: debit.documentBytes as Uint8List,
            cpfClient: debit.cpfClient,
          );
          uploadedUrls[i] = url;
        } else if (debit.documentUrl != null && debit.documentUrl!.isNotEmpty) {
          uploadedUrls[i] = debit.documentUrl;
        } else {
          uploadedUrls[i] = null;
        }
      }

      List<DebitClientModel> debitsToSave = [];
      for (int i = 0; i < debitClients.length; i++) {
        final debit = debitClients[i];
        final debitToSave = DebitClientModel(
          cpfClient: debit.cpfClient,
          value: debit.value,
          dueDate: debit.dueDate,
          dataCreation: debit.dataCreation,
          documentUrl: uploadedUrls[i],
          paid: debit.paid,
        );
        debitsToSave.add(debitToSave);
      }

      // Remove existing debits for the affected CPF(s) to avoid duplicates.
      final uniqueCpfs = debitsToSave.map((d) => d.cpfClient).toSet();
      for (final cpf in uniqueCpfs) {
        if (cpf.isNotEmpty) {
          await service.deleteDebitsByCpf(cpf);
        }
      }

      await service.addDebitClientsBatch(debitsToSave);

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
