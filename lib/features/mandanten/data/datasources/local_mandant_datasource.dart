import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:automation_app/core/general_classes/exceptions/custom_exceptions.dart';
import 'package:automation_app/features/mandanten/domain/entities/create_mandant_request.dart';
import 'package:automation_app/features/mandanten/domain/entities/mandant.dart';
import 'package:path_provider_windows/path_provider_windows.dart';

/// Lokales Mandantenregister (Req. „Daten des Kunden speichern"). Gleiches
/// Dateischema wie die übrigen lokalen Speicher: JSON-Liste im Anwendungsordner,
/// atomar geschrieben mit `.bak`-Sicherung.
abstract class LocalMandantDatasource {
  Future<List<Mandant>> loadMandanten();

  Future<Mandant> createMandant(CreateMandantRequest request);

  Future<Mandant> updateMandant(Mandant mandant);

  Future<void> deleteMandant(int id);
}

class LocalMandantDatasourceImpl implements LocalMandantDatasource {
  final File _file;

  LocalMandantDatasourceImpl._({required File file}) : _file = file;

  static Future<LocalMandantDatasourceImpl> create(
      PathProviderWindows pathProviderWindows,) async {
    final String? supportPath = await pathProviderWindows
        .getApplicationSupportPath();
    if (supportPath == null) {
      throw const MandantException('Kein Anwendungsordner gefunden');
    }
    return createInDirectory(supportPath);
  }

  /// Test-/Wiederverwendungs-Einstieg mit explizitem Verzeichnis. Stellt bei
  /// fehlender Datei aus einem evtl. vorhandenen `.bak` wieder her bzw. legt
  /// eine leere Liste an.
  static Future<LocalMandantDatasourceImpl> createInDirectory(
      String directoryPath,) async {
    final file = File('$directoryPath/mandanten.json');
    if (!await file.exists()) {
      final backup = File('${file.path}.bak');
      if (await backup.exists()) {
        await backup.rename(file.path);
      } else {
        await file.writeAsString('[]');
      }
    }
    return LocalMandantDatasourceImpl._(file: file);
  }

  @override
  Future<List<Mandant>> loadMandanten() async {
    final contents = await _file.readAsString();
    try {
      final decoded = jsonDecode(contents) as List<dynamic>;
      final mandanten = decoded
          .map((e) => Mandant.fromJson(e as Map<String, dynamic>))
          .toList();
      // Neueste zuerst — stabile Anzeige-Reihenfolge.
      mandanten.sort((a, b) => b.erstelltAm.compareTo(a.erstelltAm));
      return mandanten;
    } catch (_) {
      throw const MandantException(
        'Mandantendatei ist beschädigt und konnte nicht gelesen werden',
      );
    }
  }

  @override
  Future<Mandant> createMandant(CreateMandantRequest request) async {
    final mandanten = await loadMandanten();
    final newId = mandanten.isEmpty
        ? 1
        : mandanten.map((e) => e.id).reduce(max) + 1;

    final mandant = Mandant(
      id: newId,
      vorname: request.vorname,
      nachname: request.nachname,
      strasseHausnummer: request.strasseHausnummer,
      postleitzahl: request.postleitzahl,
      ort: request.ort,
      emailAdresse: request.emailAdresse,
      telefonnummer: request.telefonnummer,
      notiz: request.notiz,
      aktenOrdnernamen: request.aktenOrdnernamen,
      erstelltAm: DateTime.now(),
    );
    mandanten.add(mandant);
    await _writeAll(mandanten);
    return mandant;
  }

  @override
  Future<Mandant> updateMandant(Mandant mandant) async {
    final mandanten = await loadMandanten();
    final index = mandanten.indexWhere((e) => e.id == mandant.id);
    if (index == -1) {
      throw MandantException('Mandant mit ID ${mandant.id} nicht gefunden');
    }
    mandanten[index] = mandant;
    await _writeAll(mandanten);
    return mandant;
  }

  @override
  Future<void> deleteMandant(int id) async {
    final mandanten = await loadMandanten();
    final initialLength = mandanten.length;
    mandanten.removeWhere((e) => e.id == id);
    if (mandanten.length == initialLength) {
      throw MandantException('Mandant mit ID $id nicht gefunden');
    }
    await _writeAll(mandanten);
  }

  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  Future<void> _writeAll(List<Mandant> mandanten) async {
    final tmp = File('${_file.path}.tmp');
    final backup = File('${_file.path}.bak');
    try {
      // flush: true erzwingt das Schreiben auf die Platte, bevor umbenannt wird.
      await tmp.writeAsString(
        _encoder.convert(mandanten.map((e) => e.toJson()).toList()),
        flush: true,
      );

      // Auf Windows schlägt File.rename fehl, wenn das Ziel bereits existiert.
      // Deshalb das Original erst zur Seite legen, dann tmp an seine Stelle.
      if (await _file.exists()) {
        if (await backup.exists()) await backup.delete();
        await _file.rename(backup.path);
      }
      try {
        await tmp.rename(_file.path);
      } catch (_) {
        // Letztes Umbenennen fehlgeschlagen: Original aus dem Backup zurück.
        if (await backup.exists()) await backup.rename(_file.path);
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
