import 'dart:typed_data';

class DebitClientDTO {
  final String cpfClient;
  final double value;
  final String dueDate;
  final DateTime dataCreation;
  final Uint8List? documentoBytes;

  DebitClientDTO({
    required this.cpfClient,
    required this.value,
    required this.dueDate,
    required this.dataCreation,
    this.documentoBytes,
  });
}
