class ClientModel {
  String cpfClient;
  String name;
  String email;
  String phone;

  ClientModel({
    required this.cpfClient,
    required this.name,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'phone': phone};
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      cpfClient: map['cpfCliente'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
