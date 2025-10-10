class DebitClientModel {
  String id;
  String cpfClient;
  double value;
  String dueDate;
  DateTime? dataCreation;
  String? documentUrl;

  DebitClientModel({
    required this.id,
    required this.cpfClient,
    required this.value,
    required this.dueDate,
    required this.dataCreation,
    this.documentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cpfClient': cpfClient,
      'value': value,
      'dueDate': dueDate,
      'dataCreation': dataCreation?.toIso8601String(),
      'documentUrl': documentUrl,
    };
  }

  factory DebitClientModel.fromMap(Map<String, dynamic> map) {
    return DebitClientModel(
      id: map['id'] ?? '',
      cpfClient: map['cpfClient'] ?? '',
      value: (map['value'] ?? 0.0).toDouble(),
      dueDate: map['dueDate'] ?? '',
      dataCreation: map['dataCreation'] != null
          ? DateTime.parse(map['dataCreation'])
          : null,
      documentUrl: map['documentUrl'],
    );
  }
}
