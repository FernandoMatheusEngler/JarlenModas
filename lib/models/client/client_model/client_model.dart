class ClientModel {
  String cpfClient;
  String name;
  String phone;

  ClientModel({
    required this.cpfClient,
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'phone': phone, 'cpfClient': cpfClient};
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      cpfClient: map['cpfClient'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
