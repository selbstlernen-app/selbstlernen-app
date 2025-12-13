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
  IntColumn get focusPromptInterval => integer()();
  BoolColumn get showFocusPromptAlways =>
      boolean().withDefault(const Constant<bool>(false))();
  BoolColumn get hasFreetextPrompt =>
      boolean().withDefault(const Constant<bool>(true))();

  BoolColumn get isArchived =>
      boolean().withDefault(const Constant<bool>(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}
