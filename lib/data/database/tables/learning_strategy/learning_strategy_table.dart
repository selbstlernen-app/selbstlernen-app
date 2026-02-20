import 'package:drift/drift.dart';
import 'package:srl_app/data/database/tables/session_table.dart';

/// Table holding all learning strategies the user has defined
class LearningStrategies extends Table with AutoIncrementingPrimaryKey {
  /// The title of the learning strategy
  TextColumn get title => text()();

  /// Explanation of the learning strategy; does not need to be provided
  TextColumn get explanation => text().nullable()();
}
