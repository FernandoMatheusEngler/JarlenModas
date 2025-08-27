import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jarlenmodas/models/client/debit_client_model/debit_client_filter.dart';
import 'package:jarlenmodas/models/client/debit_client_model/debit_client_model.dart';

class DebitClientService {
  final CollectionReference _debitsClientsCollection = FirebaseFirestore
      .instance
      .collection('debits_clients');

  Future<List<DebitClientModel>> getDebitClient(
    DebitClientFilter filter,
  ) async {
    Query query = _debitsClientsCollection;

    if (filter.cpfClient != null && filter.cpfClient!.isNotEmpty) {
      query = query.where('cpfClient', isEqualTo: filter.cpfClient);
    }

    if (filter.startDate != null) {
      String startDateString = filter.startDate!.toIso8601String();
      query = query.where(
        'dataCreation',
        isGreaterThanOrEqualTo: startDateString,
      );
    }

    if (filter.endDate != null) {
      String endDateString = filter.endDate!.toIso8601String();
      query = query.where('dataCreation', isLessThanOrEqualTo: endDateString);
    }

    QuerySnapshot snapshot = await query.get();

    return snapshot.docs.map((doc) {
      return DebitClientModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }
}
