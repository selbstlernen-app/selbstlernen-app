import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/session_status_utils.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

Future<void> showHistoryBottomSheet(
  BuildContext context,
  List<SessionInstanceModel> instances,
  String attributeLabel,
  String Function(SessionInstanceModel) getAttributeValue,
) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: AppPalette.grey.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Session-Verlauf für \n$attributeLabel',
                        style: context.textTheme.headlineLarge,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AppPalette.grey.withValues(alpha: 0.5),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const VerticalSpace(size: SpaceSize.small),
                  Divider(
                    color: context.colorScheme.tertiary,
                    thickness: 4,
                    radius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),

            // Content with scroll controller
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: _HistorySection(
                  instances: instances,
                  getAttributeValue: getAttributeValue,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.instances,
    required this.getAttributeValue,
  });

  final List<SessionInstanceModel> instances;
  final String Function(SessionInstanceModel) getAttributeValue;

  @override
  Widget build(BuildContext context) {
    final dateTimeFormat = DateFormat('dd.MM.yy HH:mm');
    final dateOnlyFormat = DateFormat('dd.MM.yy');

    bool isSameDay(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    // Sort by date, most recent first; ignore null instances
    final sorted =
        instances.where((instance) => instance.completedAt != null).toList()
          ..sort(
            (a, b) => b.completedAt!.compareTo(a.completedAt!),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Keine Einträge verfügbar',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...List.generate(sorted.length, (index) {
              final instance = sorted[index];
              final completedAt = instance.completedAt!;

              final shouldShowTime =
                  sorted
                      .where(
                        (item) =>
                            item.completedAt != null &&
                            isSameDay(item.completedAt!, completedAt),
                      )
                      .length >
                  1;

              final displayDate = shouldShowTime
                  ? dateTimeFormat.format(completedAt)
                  : dateOnlyFormat.format(completedAt);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  leading: getIconBox(status: instance.status),
                  title: Text(
                    displayDate,
                    style: context.textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    getAttributeValue(instance),
                    style: context.textTheme.titleMedium,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              );
            }),
        ],
      ),
    );
  }
}
