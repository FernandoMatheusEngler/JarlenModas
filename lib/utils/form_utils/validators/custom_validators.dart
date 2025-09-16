import 'package:reactive_forms/reactive_forms.dart';

class CustomValidators {
  // Validador estático para CPF
  static Map<String, dynamic>? validCpf(AbstractControl<dynamic> control) {
    // Pega o valor do campo, que pode ser nulo
    final cpf = control.value as String?;

    if (cpf == null || cpf.isEmpty) {
      return null; // Não valide se estiver vazio, o 'required' cuida disso
    }

    // Remove caracteres não numéricos
    final numbers = cpf.replaceAll(RegExp(r'[^\d]'), '');

    // Verifica o tamanho e se todos os dígitos são iguais
    if (numbers.length != 11 || Set.from(numbers.split('')).length == 1) {
      return {'cpfInvalido': true};
    }

    // --- Início do Algoritmo de Validação do CPF ---
    List<int> digits = numbers.runes
        .map((rune) => int.parse(String.fromCharCode(rune)))
        .toList();

    // Calcula o primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += digits[i] * (10 - i);
    }
    int firstDigit = (sum * 10) % 11;
    if (firstDigit == 10) firstDigit = 0;

    if (firstDigit != digits[9]) {
      return {'CPF digitado está invalido, favor revise.': true};
    }

    // Calcula o segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += digits[i] * (11 - i);
    }
    int secondDigit = (sum * 10) % 11;
    if (secondDigit == 10) secondDigit = 0;

    if (secondDigit != digits[10]) {
      return {'cpfInvalido': true};
    }
    // --- Fim do Algoritmo ---

    // Se passou por todas as verificações, o CPF é válido
    return null;
  }
}
