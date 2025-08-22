import 'package:jarlenmodas/models/client/client_filter.dart';
import 'package:jarlenmodas/models/client/client_model.dart';
import 'package:jarlenmodas/services/client/client_service.dart';
import 'package:reactive_forms/reactive_forms.dart';

class UniqueCpfAsyncValidator extends AsyncValidator<dynamic> {
  @override
  Future<Map<String, dynamic>?> validate(
    AbstractControl<dynamic> control,
  ) async {
    final cpf = control.value as String?;
    if (cpf == null || cpf.isEmpty) {
      return null;
    }

    final error = {
      'Já existe um cliente com esse CPF, revise o CPF informado.': false,
    };

    final isNotUniqueCPF = await uniqueCpf(control, cpf);
    if (isNotUniqueCPF) {
      control.markAllAsTouched();
      return error;
    }

    return null;
  }

  Future<bool> uniqueCpf(AbstractControl<dynamic> control, String cpf) async {
    List<ClientModel> clients = await ClientService().getClients(
      ClientFilter(cpfClient: cpf),
    );
    return clients.isNotEmpty;
  }
}
