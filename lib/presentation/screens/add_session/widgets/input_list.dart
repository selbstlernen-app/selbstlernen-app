import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/custom_error_text.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';

class InputList<T> extends StatelessWidget {
  const InputList({
    super.key,
    required this.controller,
    required this.onEnter,
    required this.isBigGoal,
    required this.items,
    this.hideHeadline = false,
    this.toolTip,
    this.errorText,
  });

  final TextEditingController controller;
  final VoidCallback onEnter;
  final bool isBigGoal;
  final bool hideHeadline;
  final List<T> items;
  final String? toolTip;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildInputRow(context),
        if ((toolTip?.isNotEmpty ?? false) && errorText == null)
          _buildTooltip(context),
        if (errorText != null) CustomErrorText(errorText: errorText!),
        const VerticalSpace(size: SpaceSize.medium),
        if (!hideHeadline) _buildHeader(context),
        const VerticalSpace(size: SpaceSize.small),
        ..._buildItemsList(),
      ],
    );
  }

  Widget _buildInputRow(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: CustomTextField(
              onSubmitted: (_) => onEnter(),
              controller: controller,
              hintText: "Ich will...",
              hasError: errorText != null,
            ),
          ),
          const HorizontalSpace(size: SpaceSize.small),
          SizedBox(
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: onEnter,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(16),
                foregroundColor: context.colorScheme.onPrimary,
                backgroundColor: context.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        toolTip!,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      (isBigGoal) ? "Ziele (max. 5)" : "Aufgaben (max. 10)",
      style: context.textTheme.headlineSmall,
    );
  }

  List<Widget> _buildItemsList() {
    return items.map((T item) {
      final String title = item is TaskModel
          ? item.title
          : (item as GoalModel).title;
      return CustomItemTile(isLargeGoal: isBigGoal, text: title);
    }).toList();
  }
}
