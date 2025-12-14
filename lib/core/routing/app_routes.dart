import 'package:flutter/material.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/main_navigation.dart';
import 'package:srl_app/presentation/screens/active_session/active_session_screen.dart';
import 'package:srl_app/presentation/screens/add_session/add_session_screen.dart';
import 'package:srl_app/presentation/screens/detail_session/session_detail_screen.dart';
import 'package:srl_app/presentation/screens/general_statistics/statistics_screen.dart';
import 'package:srl_app/presentation/screens/reflection/reflection_screen.dart';
import 'package:srl_app/presentation/screens/session_statistics/session_statistics_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String detail = '/detail';
  static const String active = '/active';
  static const String reflection = '/reflection';
  static const String stats = '/stats';
  static const String addSession = '/add-session';
  static const String overallStatistics = '/overall-statistics';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const MainNavigation(),
          settings: const RouteSettings(name: AppRoutes.home),
        );

      case detail:
        final args = settings.arguments! as DetailSessionArgs;
        return MaterialPageRoute<dynamic>(
          builder: (_) => SessionDetailScreen(
            sessionId: args.sessionId,
            instanceId: args.instanceId,
          ),
          settings: const RouteSettings(name: AppRoutes.detail),
        );

      case active:
        final args = settings.arguments! as ActiveSessionArgs;
        return MaterialPageRoute<dynamic>(
          builder: (_) => ActiveSessionScreen(
            instanceId: args.instanceId,
            sessionId: args.sessionId,
          ),
          settings: const RouteSettings(name: AppRoutes.active),
        );

      case reflection:
        final instance = settings.arguments! as SessionInstanceModel;
        return MaterialPageRoute<dynamic>(
          builder: (_) => ReflectionScreen(instance: instance),
          settings: const RouteSettings(name: AppRoutes.reflection),
        );

      case stats:
        final args = settings.arguments! as SessionStatisticsArgs;

        return MaterialPageRoute<dynamic>(
          builder: (_) => SessionStatisticsScreen(
            sessionId: args.sessionId,
            showGeneralStatsOnly: args.showGeneralStatsOnly,
          ),
          settings: const RouteSettings(name: AppRoutes.stats),
        );

      case addSession:
        final fullSession = settings.arguments as FullSessionModel?;
        return MaterialPageRoute<dynamic>(
          builder: (_) => AddSessionScreen(fullSessionModel: fullSession),
          settings: const RouteSettings(name: AppRoutes.addSession),
        );

      case overallStatistics:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const StatisticsScreen(),
          settings: const RouteSettings(name: AppRoutes.overallStatistics),
        );
      default:
        return MaterialPageRoute<dynamic>(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

// Argument class for active session
class ActiveSessionArgs {
  ActiveSessionArgs({required this.instanceId, required this.sessionId});
  final int instanceId;
  final int sessionId;
}

class DetailSessionArgs {
  DetailSessionArgs({required this.sessionId, this.instanceId});
  final int sessionId;
  final int? instanceId;
}

class SessionStatisticsArgs {
  SessionStatisticsArgs({
    required this.sessionId,
    required this.showGeneralStatsOnly,
  });
  final int sessionId;
  final bool showGeneralStatsOnly;
}
