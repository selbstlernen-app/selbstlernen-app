import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/time_formatter.dart';

class TimeInputField extends StatelessWidget {
  const TimeInputField({super.key, required this.controller, this.onChanged});

  final TextEditingController controller;
  final Function(int)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        onChanged: onChanged != null
            ? (String value) => onChanged!(int.parse(value))
            : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: context.colorScheme.tertiary,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintText: "xx",
          hintStyle: TextStyle(color: context.colorScheme.onTertiary),
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
          const TimeFormatter(
            minValue: 1,
            maxValue: 480,
          ), // 480 min = 8 hours of learning
        ],
      ),
    );
  }
}
