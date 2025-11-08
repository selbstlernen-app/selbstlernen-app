import 'package:drift/drift.dart';

class Sessions extends Table with AutoIncrementingPrimaryKey {
  TextColumn get title => text()();

  BoolColumn get isRepeating =>
      boolean().withDefault(const Constant<bool>(false))();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get selectedDays => text().nullable()();

  TextColumn get learningStrategies => text().nullable()();

  IntColumn get focusTimeMin => integer()();
  IntColumn get breakTimeMin => integer()();
  IntColumn get longBreakTimeMin => integer()();
  IntColumn get focusPhases => integer()();

  BoolColumn get hasFocusPrompt =>
      boolean().withDefault(const Constant<bool>(true))();
  BoolColumn get hasMoodPrompt =>
      boolean().withDefault(const Constant<bool>(true))();
  BoolColumn get hasFreetextPrompt =>
      boolean().withDefault(const Constant<bool>(true))();

  IntColumn get completedInstances =>
      integer().withDefault(const Constant<int>(0))();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant<bool>(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}
