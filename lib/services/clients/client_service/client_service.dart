import 'package:firebase_auth/firebase_auth.dart';
import 'package:jarlenmodas/models/client/client_model/client_filter.dart';
import 'package:jarlenmodas/models/client/client_model/client_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientService {
  final CollectionReference _clientsCollection = FirebaseFirestore.instance
      .collection('clientes');

  Future<ClientModel> addClient(ClientModel client) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    await _clientsCollection.doc(client.cpfClient).set(client.toMap());
    return client;
  }

  Future<List<ClientModel>> getClients(ClientFilter filter) async {
    Query query = _clientsCollection;

    if (filter.name != null && filter.name!.isNotEmpty) {
      query = query.where(
        'nome',
        isGreaterThanOrEqualTo: filter.name,
        isLessThan: '${filter.name!}\uf8ff',
      );
    }

    if (filter.cpfClient != null && filter.cpfClient!.isNotEmpty) {
      query = query.where('cpfClient', isEqualTo: filter.cpfClient);
    }

    QuerySnapshot snapshot = await query.get();

    return snapshot.docs.map((doc) {
      return ClientModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> deleteClient(String cpfClient) {
    return _clientsCollection.doc(cpfClient).delete();
  }
}
