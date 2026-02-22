import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

/// Learning time type a user can be
enum LearningTimeType {
  earlyBird,
  morningLearner,
  afternoonLearner,
  eveningLearner,
  nightOwl,
  undefined,
}

/// Badge given related to the time of learning
class TimeTypeBadge extends StatelessWidget {
  const TimeTypeBadge({required this.timeType, super.key});
  final LearningTimeType timeType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: timeType.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: timeType.color,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Text(timeType.emoji, style: const TextStyle(fontSize: 16)),
          const HorizontalSpace(size: SpaceSize.xsmall),
          Text(
            timeType.label,
            style: context.textTheme.bodySmall?.copyWith(
              color: timeType.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Text box with the insights gained from the learning time type
class LearningTimeInsight extends StatelessWidget {
  const LearningTimeInsight({required this.type, super.key});
  final LearningTimeType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type.emoji, style: const TextStyle(fontSize: 16)),
          const HorizontalSpace(size: SpaceSize.xsmall),
          Expanded(
            child: Text(
              type.timeInsight,
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Extensions for the learning time type
extension LearningTimeTypeDetails on LearningTimeType {
  static LearningTimeType fromHour(int hour) {
    if (hour >= 5 && hour < 9) return LearningTimeType.earlyBird;
    if (hour >= 9 && hour < 12) return LearningTimeType.morningLearner;
    if (hour >= 12 && hour < 17) return LearningTimeType.afternoonLearner;
    if (hour >= 17 && hour < 21) return LearningTimeType.eveningLearner;
    return LearningTimeType.nightOwl; // 21:00 - 04:59
  }

  String get timeRange {
    switch (this) {
      case LearningTimeType.earlyBird:
        return '5:00–9:00';
      case LearningTimeType.morningLearner:
        return '9:00–12:00';
      case LearningTimeType.afternoonLearner:
        return '12:00–17:00';
      case LearningTimeType.eveningLearner:
        return '17:00–21:00';
      case LearningTimeType.nightOwl:
        return '21:00–5:00';
      case LearningTimeType.undefined:
        return '';
    }
  }

  String get emoji {
    switch (this) {
      case LearningTimeType.earlyBird:
        return '🐓';
      case LearningTimeType.morningLearner:
        return '☀️';
      case LearningTimeType.afternoonLearner:
        return '🌤️';
      case LearningTimeType.eveningLearner:
        return '🌙';
      case LearningTimeType.nightOwl:
        return '🦉';
      case LearningTimeType.undefined:
        return '';
    }
  }

  String get label {
    switch (this) {
      case LearningTimeType.earlyBird:
        return 'Frühaufsteher';
      case LearningTimeType.morningLearner:
        return 'Morgentyp';
      case LearningTimeType.afternoonLearner:
        return 'Mittagstyp';
      case LearningTimeType.eveningLearner:
        return 'Abendtyp';
      case LearningTimeType.nightOwl:
        return 'Nachteulen-Typ';
      case LearningTimeType.undefined:
        return '';
    }
  }

  String get timeInsight {
    switch (this) {
      case LearningTimeType.earlyBird:
        return 'Du lernst am liebsten in der Frühe. Nutze '
            'deine Wachheit optimal.';
      case LearningTimeType.morningLearner:
        return 'Der Vormittag ist deine produktivste Zeit. Plane '
            'anspruchsvolle Inhalte gezielt in diese Stunden.';
      case LearningTimeType.afternoonLearner:
        return 'Du arbeitest am häufig nachmittags. Schütze dieses Zeitfenster '
            'vor anderen Verpflichtungen.';
      case LearningTimeType.eveningLearner:
        return 'Du lernst häufig abends. Achte darauf, '
            'nicht zu spät zu lernen, damit dein Schlaf nicht leidet.';
      case LearningTimeType.nightOwl:
        return 'Du bist eine echte Nachteule. Achte auf ausreichend '
            'Schlaf als Ausgleich.';
      case LearningTimeType.undefined:
        return '';
    }
  }

  Color get color {
    switch (this) {
      case LearningTimeType.earlyBird:
        return AppPalette.yellowLight;
      case LearningTimeType.morningLearner:
        return AppPalette.amber;
      case LearningTimeType.afternoonLearner:
        return AppPalette.emerald;
      case LearningTimeType.eveningLearner:
        return AppPalette.orange;
      case LearningTimeType.nightOwl:
        return AppPalette.indigo;
      case LearningTimeType.undefined:
        return AppPalette.grey;
    }
  }
}
