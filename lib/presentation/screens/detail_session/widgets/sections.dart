import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/goal_model.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/models/task_model.dart';

// 1. Session Info Card
class SessionInfoCard extends StatelessWidget {
  const SessionInfoCard({super.key, required this.session});

  final SessionModel session;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(session.title, style: context.textTheme.headlineMedium),
            const SizedBox(height: 8),

            // Schedule info
            Row(
              children: <Widget>[
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  session.isRepeating
                      ? 'Wiederkehrend (${_formatWeekdays(session.selectedDays)})'
                      : 'Einmalig',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                const Icon(Icons.date_range, size: 20),
                const SizedBox(width: 8),
                Text(_formatDateRange(session)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatWeekdays(List<int> weekdays) {
    final List<String> days = <String>[
      'Mo',
      'Di',
      'Mi',
      'Do',
      'Fr',
      'Sa',
      'So',
    ];
    return weekdays.map((int d) => days[d - 1]).join(', ');
  }

  String _formatDateRange(SessionModel session) {
    final String start = (session.startDate!).day.toString();
    if (session.endDate != null) {
      final DateTime end = (session.endDate!);
      return '$start - $end';
    }
    return start;
  }
}

// 3. Goals Section
class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key, required this.goals});

  final List<GoalModel> goals;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Ziele (${goals.length})',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...goals.map(
              (GoalModel goal) => ListTile(
                leading: const Icon(Icons.flag),
                title: Text(goal.title),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. Tasks Section (similar to goals)
class TasksSection extends StatelessWidget {
  const TasksSection({super.key, required this.tasks});

  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Aufgaben (${tasks.length})',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...tasks.map(
              (TaskModel task) => ListTile(
                leading: const Icon(Icons.check_box_outline_blank),
                title: Text(task.title),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. History Section
class HistorySection extends StatelessWidget {
  const HistorySection({super.key, required this.instances});

  final List<SessionInstanceModel> instances;

  @override
  Widget build(BuildContext context) {
    // Sort by date, most recent first
    final List<SessionInstanceModel> sorted =
        <SessionInstanceModel>[...instances]..sort(
          (SessionInstanceModel a, SessionInstanceModel b) =>
              b.scheduledAt.compareTo(a.scheduledAt),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Verlauf', style: context.textTheme.titleLarge),
            const SizedBox(height: 12),
            ...sorted
                .take(5)
                .map(
                  (SessionInstanceModel instance) => ListTile(
                    leading: Icon(
                      instance.status == SessionStatus.completed
                          ? Icons.check_circle
                          : Icons.skip_next,
                      color: instance.status == SessionStatus.completed
                          ? Colors.green
                          : Colors.orange,
                    ),
                    title: Text((instance.scheduledAt).toString()),
                    subtitle: Text(
                      '${instance.totalFocusSecondsElapsed ~/ 60} min Fokuszeit',
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            if (sorted.length > 5)
              TextButton(
                onPressed: () {
                  // Navigate to full history screen
                },
                child: const Text('Alle anzeigen'),
              ),
          ],
        ),
      ),
    );
  }
}
