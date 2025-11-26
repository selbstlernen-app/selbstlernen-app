import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/custom_error_text.dart';
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

    // Initialize after build; if in edit mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AddSessionState state = ref.read(addSessionViewModelProvider);
      if (state.isEditingMode) {
        _startDateController.text = state.startDate != null
            ? DateTimeUtils.dateTimeToString(date: state.startDate!)
            : "";
        _endDateController.text = state.endDate != null
            ? DateTimeUtils.dateTimeToString(date: state.endDate!)
            : "";
      }
    });
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

        // Pick weekdays
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: dayNames.map((String day) {
            final int dayIndex = dayNames.indexOf(day);
            final bool isSelected = state.selectedDays.contains(dayIndex);

            return InkWell(
              onTap: () => ref
                  .read(addSessionViewModelProvider.notifier)
                  .toggleDay(dayIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 8.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      day,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: isSelected
                            ? context.colorScheme.primary
                            : context.colorScheme.onTertiary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    // Line underneath weekday
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      height: 2,
                      width: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        if (state.selectedDaysError != null)
          CustomErrorText(errorText: state.selectedDaysError!),

        const VerticalSpace(size: SpaceSize.medium),

        // Pick start and end dates
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Startdatum",
                    style: context.textTheme.headlineSmall!.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const VerticalSpace(size: SpaceSize.xsmall),
                  CustomTextField(
                    controller: _startDateController,
                    readOnly: true,
                    hintText: "Startdatum",
                    onTap: () => _pickDate(_startDateController, true),
                    hasError: state.dateError != null,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Enddatum",
                    style: context.textTheme.headlineSmall!.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const VerticalSpace(size: SpaceSize.xsmall),
                  CustomTextField(
                    controller: _endDateController,
                    readOnly: true,
                    hintText: "Enddatum",
                    onTap: () => _pickDate(_endDateController, false),
                    hasError: state.dateError != null,
                  ),
                ],
              ),
            ),
          ],
        ),

        if (state.dateError != null)
          CustomErrorText(errorText: state.dateError!),
      ],
    );
  }
}
