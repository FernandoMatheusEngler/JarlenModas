import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CurrencyValueAccessor extends ControlValueAccessor<double, String> {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  String? modelToViewValue(double? modelValue) {
    if (modelValue == null) return null;
    return _formatter.format(modelValue);
  }

  @override
  double? viewToModelValue(String? viewValue) {
    if (viewValue == null || viewValue.trim().isEmpty) return null;

    // Remove qualquer coisa que não seja dígito ou vírgula
    final numericString = viewValue.replaceAll(RegExp(r'[^0-9,]'), '');
    if (numericString.isEmpty) return null;

    // Troca vírgula por ponto para parsear double
    final parsed = numericString.replaceAll(',', '.');
    return double.tryParse(parsed);
  }
}
