import 'package:drift/drift.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: <Type>[Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  // Get setting by key
  Future<Setting> getSetting() async {
    final row = await select(settings).getSingleOrNull();
    if (row != null) return row;

    // Insert defaults ONCE if no row is given
    final defaultRow = SettingsCompanion.insert(
      id: const Value(0),
      isDarkMode: const Value(false),
      primaryColor: Value(AppPalette.sky.toARGB32()),
    );

    await into(settings).insert(defaultRow);
    return select(settings).getSingle();
  }

  // Set dark mode setting
  Future<void> saveDarkMode({required bool isDark}) async {
    await into(settings).insert(
      SettingsCompanion(
        id: const Value(0),
        isDarkMode: Value(isDark),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  // Save primary color
  Future<void> savePrimaryColor(int colorValue) async {
    await into(settings).insert(
      SettingsCompanion(
        id: const Value(0),
        primaryColor: Value(colorValue),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  // Watch settings
  Stream<Setting> watchSettings() {
    return (select(settings)..where((t) => t.id.equals(0))).watchSingle();
  }
}
