import 'package:flutter/services.dart';

class TimeFormatter extends TextInputFormatter {
  const TimeFormatter({required this.minValue, required this.maxValue});
  final int minValue;
  final int maxValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == "") {
      return const TextEditingValue();
    }
    return int.parse(newValue.text) > maxValue
        ? const TextEditingValue().copyWith(text: maxValue.toString())
        : newValue;
  }
}
