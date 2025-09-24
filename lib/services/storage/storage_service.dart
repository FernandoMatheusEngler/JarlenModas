import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadWebpImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      // Cria uma referência para o local onde o arquivo será salvo no Storage
      // Ex: 'debit_documents/meu_arquivo_unico.webp'
      final Reference ref = _storage.ref('debit_documents').child(fileName);

      // Define os metadados do arquivo, especificando que é uma imagem WebP
      final metadata = SettableMetadata(contentType: 'image/webp');

      // Faz o upload dos bytes da imagem
      final UploadTask uploadTask = ref.putData(imageBytes, metadata);

      // Aguarda a conclusão do upload
      final TaskSnapshot snapshot = await uploadTask;

      // Obtém a URL de download do arquivo que acabamos de enviar
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      // Trata possíveis erros de upload
      final errorMessage = 'Erro ao fazer upload da imagem: ${e.message}';
      return errorMessage;
    }
  }
}
