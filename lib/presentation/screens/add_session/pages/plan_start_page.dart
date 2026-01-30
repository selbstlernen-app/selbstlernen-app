import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/date_input_fields.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class PlanStartPage extends ConsumerStatefulWidget {
  const PlanStartPage({required this.navigateForward, super.key});
  final VoidCallback navigateForward;

  @override
  ConsumerState<PlanStartPage> createState() => _PlanStartPageState();
}

class _PlanStartPageState extends ConsumerState<PlanStartPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addSessionViewModelProvider);
    final plannedTime = ref.watch(
      addSessionViewModelProvider.select((s) => s.plannedTime),
    );

    final notificationsEnabled = ref.watch(
      addSessionViewModelProvider.select((s) => s.enableNotifications),
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            // Date and days
            if (state.isRepeating) ...[
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.calendar_month_outlined,
                  ),
                  const HorizontalSpace(size: SpaceSize.small),
                  Text(
                    'An welchen Tagen willst du lernen?',
                    style: context.textTheme.headlineSmall,
                  ),
                ],
              ),
              const DateInputFields(),
              const VerticalSpace(size: SpaceSize.xlarge),
            ],

            // Schedule Time
            Row(
              children: <Widget>[
                const Icon(
                  Icons.notification_important_outlined,
                ),
                const HorizontalSpace(size: SpaceSize.small),
                Text(
                  'Um wie viel Uhr willst du lernen?',
                  style: context.textTheme.headlineSmall,
                ),
              ],
            ),
            const VerticalSpace(),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  color: context.colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    plannedTime.format(context),
                    style: context.textTheme.bodyLarge,
                  ),
                ),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: plannedTime,
                );
                if (time != null) {
                  ref
                      .read(addSessionViewModelProvider.notifier)
                      .setPlannedTime(time);
                }
              },
            ),
            const VerticalSpace(),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Willst du Benachrichtigungen für diese Einheit einschalten?',
                    style: context.textTheme.bodyMedium,
                  ),
                ),
                Theme(
                  data: ThemeData(useMaterial3: true).copyWith(
                    colorScheme: context.colorScheme.copyWith(
                      outline: context.colorScheme.onTertiary,
                    ),
                  ),
                  child: Switch(
                    value: notificationsEnabled,
                    inactiveThumbColor: context.colorScheme.onTertiary,
                    onChanged: (bool value) async {
                      await ref
                          .read(addSessionViewModelProvider.notifier)
                          .enableNotifications(isEnabled: value);
                    },
                  ),
                ),
              ],
            ),

            const VerticalSpace(
              size: SpaceSize.small,
            ),

            // Information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: context.colorScheme.primary,
                  ),
                  const HorizontalSpace(size: SpaceSize.small),
                  Expanded(
                    child: Text(
                      '''Die Uhrzeit dient nur der Planung und Benachrichtigung. Du kannst die Einheit trotzdem jederzeit starten.''',
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),

        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'Weiter',
                    isActive: ref
                        .read(addSessionViewModelProvider)
                        .canGoToThirdPage,
                    onPressed: () =>
                        ref.read(addSessionViewModelProvider).canGoToThirdPage
                        ? widget.navigateForward()
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
