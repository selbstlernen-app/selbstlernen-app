import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/time_formatter.dart';

class TimeInputField extends StatelessWidget {
  const TimeInputField({
    required this.controller,
    required this.label,
    required this.onChanged,
    super.key,
    this.minValue = 1,
    this.maxValue = 480, // 480 min = 8 hours of learning
  });

  final TextEditingController controller;
  final ValueChanged<int> onChanged;
  final String label;
  final int minValue;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 150,
            child: Text(
              label,
              maxLines: 2,
              style: context.textTheme.headlineSmall!.copyWith(
                fontSize: 16,
                color: context.colorScheme.primary,
              ),
            ),
          ),
          const VerticalSpace(size: SpaceSize.xsmall),
          SizedBox(
            width: 150,
            child: TextField(
              controller: controller,
              onChanged: (String value) {
                if (value.isEmpty) {
                  onChanged(0);
                  return;
                }
                final parsed = int.tryParse(value);
                if (parsed == null) {
                  return;
                } else {
                  onChanged(parsed);
                }
              },

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
                hintText: 'xxx',
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
