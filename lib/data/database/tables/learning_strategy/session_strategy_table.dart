import 'package:drift/drift.dart';
import 'package:srl_app/data/database/tables/learning_strategy/learning_strategy_table.dart';
import 'package:srl_app/data/database/tables/session_table.dart';

// Table linking session to strategy
class SessionStrategies extends Table with AutoIncrementingPrimaryKey {
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get strategyId => integer().references(
    LearningStrategies,
    #id,
    onDelete: KeyAction.cascade,
  )();
}
