class ClientModel {
  final String cpfClient;
  final String nome;
  final String email;
  final String telefone;

  ClientModel({
    required this.cpfClient,
    required this.nome,
    required this.email,
    required this.telefone,
  });

  Map<String, dynamic> toMap() {
    return {'nome': nome, 'email': email, 'telefone': telefone};
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      cpfClient: map['cpfCliente'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'] ?? '',
    );
  }
}
