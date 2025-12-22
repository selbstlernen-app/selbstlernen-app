import 'package:drift/drift.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/settings_table.dart';

part 'settings_dao.g.dart';

// TODO: later rework with notification settings etc.
@DriftAccessor(tables: <Type>[Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  // Get settings
  Future<Setting> getSetting() async {
    return await select(settings).getSingle();
  }
}
