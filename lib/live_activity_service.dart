import 'package:live_activities/live_activities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'live_activity_service.g.dart';

@riverpod
class LiveActivityService extends _$LiveActivityService {
  final _plugin = LiveActivities();
  String? _latestActivityId;

  @override
  void build() {
    _plugin.init(appGroupId: 'group.com.masterthesis.srl.app');
  }

  Future<void> start({
    required int secondsRemaining,
    required String title,
  }) async {
    await stop();

    final endTime = DateTime.now().add(Duration(seconds: secondsRemaining));

    final activityData = {
      'name': title,
      'endTime': endTime.millisecondsSinceEpoch.toDouble(),
    };

    _latestActivityId = await _plugin.createActivity(
      DateTime.now().millisecondsSinceEpoch.toString(),
      activityData,
    );
  }

  Future<void> update({
    required int secondsRemaining,
    required String title,
  }) async {
    if (_latestActivityId == null) {
      await start(secondsRemaining: secondsRemaining, title: title);
      return;
    }

    final endTime = DateTime.now().add(Duration(seconds: secondsRemaining));

    await _plugin.updateActivity(_latestActivityId!, {
      'name': title,
      'endTime': endTime.millisecondsSinceEpoch.toDouble(),
    });
  }

  Future<void> stop() async {
    await _plugin.endAllActivities();
    _latestActivityId = null;
  }
}
