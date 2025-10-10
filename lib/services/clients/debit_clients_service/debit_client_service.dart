import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jarlenmodas/models/client/debit_client_model/debit_client_filter.dart';
import 'package:jarlenmodas/models/client/debit_client_model/debit_client_model.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class DebitClientService {
  final CollectionReference _debitsClientsCollection = FirebaseFirestore
      .instance
      .collection('debits_clients');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<DebitClientModel>> getDebitClient(
    DebitClientFilter filter,
  ) async {
    Query query = _debitsClientsCollection;

    if (filter.cpfClient != null && filter.cpfClient!.isNotEmpty) {
      query = query.where('cpfClient', isEqualTo: filter.cpfClient);
    }
    query = query.orderBy('value', descending: true);
    QuerySnapshot snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return DebitClientModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> addDebitClient(DebitClientModel debitClient) async {
    DocumentReference docRef = await _debitsClientsCollection.add(
      debitClient.toMap(),
    );
    await docRef.update({'id': docRef.id});
  }

  Future<String> uploadDocumentAsWebP({
    required Uint8List imageBytes,
    required String cpfClient,
  }) async {
    try {
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception("Não foi possível decodificar a imagem.");
      }

      final fileName = '${const Uuid().v4()}.webp';
      final filePath = 'debit_documents/$cpfClient/$fileName';

      final ref = _storage.ref(filePath);
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/webp'),
      );
      final snapshot = await uploadTask.whenComplete(() => {});

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload do documento: $e');
    }
  }
}
