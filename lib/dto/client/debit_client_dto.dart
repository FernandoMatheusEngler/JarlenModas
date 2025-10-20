import 'dart:typed_data';

class DebitClientDTO {
  final String cpfClient;
  final double value;
  final String dueDate;
  final DateTime dataCreation;
  // when creating/updating we can either send raw bytes (new upload)
  // or keep an existing documentUrl (already uploaded)
  final Uint8List? documentBytes;
  final String? documentUrl;
  final bool paid;

  DebitClientDTO({
    required this.cpfClient,
    required this.value,
    required this.dueDate,
    required this.dataCreation,
    this.documentBytes,
    this.documentUrl,
    this.paid = false,
  });
}
