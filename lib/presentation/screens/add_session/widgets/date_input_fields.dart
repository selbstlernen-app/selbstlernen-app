import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/date_time_utils.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class DateInputFields extends ConsumerStatefulWidget {
  const DateInputFields({super.key});

  @override
  ConsumerState<DateInputFields> createState() => _DateInputFieldsState();
}

class _DateInputFieldsState extends ConsumerState<DateInputFields> {
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  static const List<String> dayNames = <String>[
    "Mo",
    "Di",
    "Mi",
    "Do",
    "Fr",
    "Sa",
    "So",
  ];

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    TextEditingController controller,
    bool isStartDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.text = DateTimeUtils.dateTimeToString(date: picked);

      if (isStartDate) {
        ref.read(addSessionViewModelProvider.notifier).setStartDate(picked);
      } else {
        ref.read(addSessionViewModelProvider.notifier).setEndDate(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AddSessionState state = ref.watch(addSessionViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const VerticalSpace(size: SpaceSize.medium),

        Text("Jede Woche", style: context.textTheme.headlineSmall),
        const VerticalSpace(size: SpaceSize.small),
        Center(
          child: Wrap(
            spacing: 24,
            children: dayNames.map((String day) {
              final int dayIndex = dayNames.indexOf(day);
              final bool isSelected = state.selectedDays.contains(dayIndex);

              return InkWell(
                onTap: () => ref
                    .read(addSessionViewModelProvider.notifier)
                    .toggleDay(dayIndex),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      day,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      height: 2,
                      width: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        if (state.selectedDaysError != null)
          Text(
            state.selectedDaysError!,
            style: TextStyle(color: context.colorScheme.error, fontSize: 14),
          ),

        const VerticalSpace(size: SpaceSize.medium),

        Text("ab dem", style: context.textTheme.headlineSmall),
        const VerticalSpace(size: SpaceSize.small),
        CustomTextField(
          controller: _startDateController,
          readOnly: true,
          hintText: "Startdatum auswählen",
          onTap: () => _pickDate(_startDateController, true),
          errorText: state.startDateError,
        ),

        const VerticalSpace(size: SpaceSize.medium),

        Text("bis zum", style: context.textTheme.headlineSmall),
        const VerticalSpace(size: SpaceSize.small),
        CustomTextField(
          controller: _endDateController,
          readOnly: true,
          hintText: "Enddatum auswählen",
          onTap: () => _pickDate(_endDateController, false),
          errorText: state.endDateError,
        ),
      ],
    );
  }
}
