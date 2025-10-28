import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/time_formatter.dart';

class TimeInputField extends StatelessWidget {
  const TimeInputField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
    this.minValue = 1,
    this.maxValue = 480, // 480 min = 8 hours of learning
  });

  final TextEditingController controller;
  final Function(int)? onChanged;
  final String label;
  final int minValue;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          SizedBox(
            width: 65,
            child: TextField(
              controller: controller,
              onChanged: onChanged != null
                  ? (String value) => onChanged!(int.parse(value))
                  : null,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: context.colorScheme.tertiary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: "xxx",
                hintStyle: TextStyle(color: context.colorScheme.onTertiary),
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
                TimeFormatter(minValue: minValue, maxValue: maxValue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
