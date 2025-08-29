import 'dart:typed_data';

class DebitClientModel {
  String id;
  String cpfClient;
  // PaymentMethodType paymentMethod;
  double value;
  String dueDate;
  DateTime? dataCreation;
  Uint8List? document;

  DebitClientModel({
    required this.id,
    required this.cpfClient,
    // required this.paymentMethod,
    required this.value,
    required this.dueDate,
    required this.dataCreation,
    this.document,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cpfClient': cpfClient,
      // 'paymentMethod': paymentMethod.name,
      'value': value,
      'dueDate': dueDate,
      'dataCreation': dataCreation?.toIso8601String(),
      'document': document,
    };
  }

  factory DebitClientModel.fromMap(Map<String, dynamic> map) {
    return DebitClientModel(
      id: map['id'] ?? '',
      cpfClient: map['cpfClient'] ?? '',
      // paymentMethod: _stringToPaymentMethodType(map['paymentMethod'] ?? ''),
      value: (map['value'] ?? 0.0).toDouble(),
      dueDate: map['dueDate'] ?? '',
      dataCreation: map['dataCreation'] != null
          ? DateTime.parse(map['dataCreation'])
          : null,
      document: map['document'] != null
          ? Uint8List.fromList(List<int>.from(map['digitizedDocument']))
          : null,
    );
  }

  // static PaymentMethodType _stringToPaymentMethodType(String? methodName) {
  //   switch (methodName) {
  //     case 'Cartão de Crédito':
  //       return PaymentMethodType.creditCard;
  //     case 'Cartão de Débito':
  //       return PaymentMethodType.debitCard;
  //     case 'Pix':
  //       return PaymentMethodType.pix;
  //     case 'Dinheiro':
  //       return PaymentMethodType.cash;
  //     default:
  //       return PaymentMethodType.other;
  //   }
  // }
}

enum PaymentMethodType { creditCard, debitCard, pix, cash, other }
