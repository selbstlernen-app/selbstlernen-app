import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/custom_error_text.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
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
    'Mo',
    'Di',
    'Mi',
    'Do',
    'Fr',
    'Sa',
    'So',
  ];

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();

    // Initialize after build; if in edit mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(addSessionViewModelProvider);
      if (state.isEditMode) {
        _startDateController.text = state.startDate != null
            ? DateFormat('dd.MM.yyyy').format(state.startDate!)
            : '';
        _endDateController.text = state.endDate != null
            ? DateFormat('dd.MM.yyyy').format(state.endDate!)
            : '';
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
    DateTime? lastTypedDate;
    if (controller.text.isNotEmpty) {
      lastTypedDate = DateFormat('dd.MM.yyyy').parse(controller.text);
    }

    final today = DateTime.now();
    final normalizedToday = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final effectiveLastDate = lastTypedDate == null
        ? null
        : DateTime(lastTypedDate.year, lastTypedDate.month, lastTypedDate.day);

    final firstDate = (isStartDate && effectiveLastDate != null)
        ? (effectiveLastDate.isAfter(normalizedToday)
              ? normalizedToday // fallback to todays date
              : effectiveLastDate) // else go with last date
        : normalizedToday;

    final picked = await showDatePicker(
      helpText: isStartDate ? 'Startdatum auswählen' : 'Enddatum auswählen',
      context: context,
      initialDate: lastTypedDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.text = DateFormat('dd.MM.yyyy').format(picked);

      if (isStartDate) {
        ref.read(addSessionViewModelProvider.notifier).setStartDate(picked);

        // After having picked a start date, automatically open
        // end date calendar
        await Future<Null>.delayed(
          const Duration(milliseconds: 200),
          () async {
            await _pickDate(_endDateController, false);
          },
        );
      } else {
        ref.read(addSessionViewModelProvider.notifier).setEndDate(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addSessionViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const VerticalSpace(),

        // Pick weekdays
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: dayNames.map((String day) {
            final dayIndex = dayNames.indexOf(day);
            final isSelected = state.selectedDays.contains(dayIndex);

            return InkWell(
              onTap: () => state.isEditMode
                  ? null
                  : ref
                        .read(addSessionViewModelProvider.notifier)
                        .toggleDay(dayIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
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

        const VerticalSpace(),

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
                    'Startdatum',
                    style: context.textTheme.headlineSmall!.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const VerticalSpace(size: SpaceSize.xsmall),
                  CustomTextField(
                    controller: _startDateController,
                    readOnly: true,
                    hintText: 'Startdatum',
                    onTap: () => state.isEditMode
                        ? null
                        : _pickDate(_startDateController, true),
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
                    'Enddatum',
                    style: context.textTheme.headlineSmall!.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const VerticalSpace(size: SpaceSize.xsmall),
                  CustomTextField(
                    controller: _endDateController,
                    readOnly: true,
                    hintText: 'Enddatum',
                    onTap: () => state.isEditMode
                        ? null
                        : _pickDate(_endDateController, false),
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
