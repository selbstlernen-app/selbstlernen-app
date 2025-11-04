import 'package:drift/drift.dart';

class Sessions extends Table with AutoIncrementingPrimaryKey {
  TextColumn get title => text()();

  BoolColumn get isRepeating =>
      boolean().withDefault(const Constant<bool>(false))();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get selectedDays => text().nullable()();

  TextColumn get learningStrategies => text().nullable()();

  IntColumn get totalTimeMin => integer().nullable()();
  IntColumn get focusTimeMin => integer().nullable()();
  IntColumn get breakTimeMin => integer().nullable()();
  IntColumn get longBreakTimeMin => integer().nullable()();
  IntColumn get focusPhases => integer().nullable()();

  BoolColumn get hasFocusPrompt =>
      boolean().withDefault(const Constant<bool>(true))();
  BoolColumn get hasMoodPrompt =>
      boolean().withDefault(const Constant<bool>(true))();
  BoolColumn get hasFreetextPrompt =>
      boolean().withDefault(const Constant<bool>(true))();

  IntColumn get completedInstances =>
      integer().withDefault(const Constant<int>(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}
