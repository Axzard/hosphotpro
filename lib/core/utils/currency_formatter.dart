import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class CurrencyFormatter extends TextInputFormatter {
  static String format(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(value).trim();
  }

  static double parse(String value) {
    if (value.isEmpty) return 0;
    return double.tryParse(value.replaceAll('.', '')) ?? 0;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final String cleanText = newValue.text.replaceAll('.', '');
    final double value = double.tryParse(cleanText) ?? 0;
    
    final String formatted = format(value);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
