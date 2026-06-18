import 'dart:convert';
import 'dart:io';

import 'package:automation_app/core/general_classes/exceptions/custom_exceptions.dart';
import 'package:automation_app/features/settings/domain/entities/kanzlei_settings.dart';
import 'package:path_provider_windows/path_provider_windows.dart';

abstract class LocalKanzleiSettingsDatasource {
  Future<KanzleiSettings> loadSettings();

  Future<KanzleiSettings> saveSettings(KanzleiSettings settings);
}

class LocalKanzleiSettingsDatasourceImpl
    implements LocalKanzleiSettingsDatasource {
  final File _settingsFile;

  LocalKanzleiSettingsDatasourceImpl._({required File settingsFile})
      : _settingsFile = settingsFile;

  static Future<LocalKanzleiSettingsDatasourceImpl> create(
      PathProviderWindows pathProviderWindows,) async {
    final String? supportPath = await pathProviderWindows
        .getApplicationSupportPath();
    if (supportPath == null) {
      throw const SettingsException('Kein Anwendungsordner gefunden');
    }
    final file = File('$supportPath/kanzlei_settings.json');
    return LocalKanzleiSettingsDatasourceImpl._(settingsFile: file);
  }

  @override
  Future<KanzleiSettings> loadSettings() async {
    // Noch nie gespeichert: leere Standardwerte zurückgeben (kein Fehler).
    if (!await _settingsFile.exists()) {
      final backup = File('${_settingsFile.path}.bak');
      if (!await backup.exists()) {
        return KanzleiSettings.empty;
      }
      await backup.rename(_settingsFile.path);
    }

    final contents = await _settingsFile.readAsString();
    try {
      final decoded = jsonDecode(contents) as Map<String, dynamic>;
      return KanzleiSettings.fromJson(decoded);
    } catch (_) {
      throw const SettingsException(
        'Einstellungsdatei ist beschädigt und konnte nicht gelesen werden',
      );
    }
  }

  @override
  Future<KanzleiSettings> saveSettings(KanzleiSettings settings) async {
    await _writeAtomically(settings);
    return settings;
  }

  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  Future<void> _writeAtomically(KanzleiSettings settings) async {
    final tmp = File('${_settingsFile.path}.tmp');
    final backup = File('${_settingsFile.path}.bak');
    try {
      // flush: true erzwingt das Schreiben auf die Platte, bevor umbenannt wird.
      await tmp.writeAsString(_encoder.convert(settings.toJson()), flush: true);

      // Auf Windows schlägt File.rename fehl, wenn das Ziel bereits existiert.
      // Deshalb das Original erst zur Seite legen, dann tmp an seine Stelle.
      if (await _settingsFile.exists()) {
        if (await backup.exists()) await backup.delete();
        await _settingsFile.rename(backup.path);
      }
      try {
        await tmp.rename(_settingsFile.path);
      } catch (_) {
        // Letztes Umbenennen fehlgeschlagen: Original aus dem Backup zurück.
        if (await backup.exists()) await backup.rename(_settingsFile.path);
        rethrow;
      }
      // Erfolg: Backup ist best-effort, ein Rest-.bak ist unkritisch.
      try {
        if (await backup.exists()) await backup.delete();
      } catch (_) {}
    } catch (e) {
      if (await tmp.exists()) await tmp.delete();
      rethrow;
    }
  }
}
