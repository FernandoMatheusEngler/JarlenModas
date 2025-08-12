import 'package:jarlenmodas/models/client/client_filter.dart';
import 'package:jarlenmodas/models/client/client_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientService {
  final CollectionReference _clientsCollection = FirebaseFirestore.instance
      .collection('clientes');

  Future<void> addClient(ClientModel client) {
    return _clientsCollection.doc(client.cpfClient).set(client.toMap());
  }

  Future<List<ClientModel>> getClients(ClientFilter filter) async {
    Query query = _clientsCollection;

    if (filter.nome != null && filter.nome!.isNotEmpty) {
      query = query.where(
        'nome',
        isGreaterThanOrEqualTo: filter.nome,
        isLessThan: '${filter.nome!}\uf8ff',
      );
    }

    if (filter.cpfCliente != null && filter.cpfCliente!.isNotEmpty) {
      query = query.where('cpfCliente', isEqualTo: filter.cpfCliente);
    }

    QuerySnapshot snapshot = await query.get();

    return snapshot.docs.map((doc) {
      return ClientModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> updateClient(ClientModel client) {
    return _clientsCollection.doc(client.cpfClient).update(client.toMap());
  }

  Future<void> deleteClient(String cpfClient) {
    return _clientsCollection.doc(cpfClient).delete();
  }
}
