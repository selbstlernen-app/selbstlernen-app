import 'package:drift/drift.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: <Type>[Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  // Settings keys
  static const String keyDarkMode = 'dark_mode';
  static const String keyPrimaryColor = 'primary_color';

  // Get setting by key
  Future<String?> getSetting(String key) async {
    final query = select(settings)..where((t) => t.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  // Set or update setting
  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ),
    );
  }

  // Get dark mode setting
  Future<bool> getDarkMode() async {
    final value = await getSetting(keyDarkMode);
    return value == 'true';
  }

  // Set dark mode setting
  Future<void> setDarkMode({required bool isDark}) async {
    await setSetting(keyDarkMode, isDark.toString());
  }

  // Get primary color setting
  Future<int> getPrimaryColor() async {
    final value = await getSetting(keyPrimaryColor);
    return value != null ? int.parse(value) : AppPalette.sky.toARGB32();
  }

  // Set primary color setting
  Future<void> setPrimaryColor(int colorValue) async {
    await setSetting(keyPrimaryColor, colorValue.toString());
  }

  // Watch dark mode changes
  Stream<bool> watchDarkMode() {
    return (select(settings)..where((t) => t.key.equals(keyDarkMode)))
        .watchSingleOrNull()
        .map((setting) => setting?.value == 'true');
  }

  // Watch primary color changes
  Stream<int> watchPrimaryColor() {
    return (select(settings)..where((t) => t.key.equals(keyPrimaryColor)))
        .watchSingleOrNull()
        .map((setting) {
          if (setting?.value != null) {
            return int.parse(setting!.value);
          }
          return AppPalette.sky.toARGB32();
        });
  }
}
