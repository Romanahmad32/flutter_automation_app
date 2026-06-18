import 'dart:io';

import 'package:automation_app/core/general_classes/exceptions/custom_exceptions.dart';
import 'package:automation_app/features/mandanten/data/datasources/local_mandant_datasource.dart';
import 'package:automation_app/features/mandanten/domain/entities/create_mandant_request.dart';
import 'package:automation_app/features/mandanten/domain/entities/mandant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mandant_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<LocalMandantDatasourceImpl> erstelleDatasource() =>
      LocalMandantDatasourceImpl.createInDirectory(tempDir.path);

  test('startet mit leerer Liste', () async {
    final ds = await erstelleDatasource();
    expect(await ds.loadMandanten(), isEmpty);
  });

  test('createMandant vergibt fortlaufende IDs', () async {
    final ds = await erstelleDatasource();
    final erster = await ds.createMandant(
      const CreateMandantRequest(vorname: 'Max', nachname: 'Bein'),
    );
    final zweiter = await ds.createMandant(
      const CreateMandantRequest(nachname: 'Müller'),
    );

    expect(erster.id, 1);
    expect(zweiter.id, 2);
    expect(erster.anzeigename, 'Max Bein');

    final geladen = await ds.loadMandanten();
    expect(geladen, hasLength(2));
  });

  test('updateMandant persistiert Änderungen', () async {
    final ds = await erstelleDatasource();
    final m = await ds.createMandant(
      const CreateMandantRequest(nachname: 'Bein'),
    );

    await ds.updateMandant(m.copyWith(ort: 'Bad Homburg'));

    final geladen = (await ds.loadMandanten()).single;
    expect(geladen.ort, 'Bad Homburg');
  });

  test('updateMandant wirft bei unbekannter ID', () async {
    final ds = await erstelleDatasource();
    final unbekannt = Mandant(
        id: 999, nachname: 'Geist', erstelltAm: DateTime.now());

    expect(
          () => ds.updateMandant(unbekannt),
      throwsA(isA<MandantException>()),
    );
  });

  test('deleteMandant entfernt und wirft bei unbekannter ID', () async {
    final ds = await erstelleDatasource();
    final m = await ds.createMandant(
      const CreateMandantRequest(nachname: 'Bein'),
    );

    await ds.deleteMandant(m.id);
    expect(await ds.loadMandanten(), isEmpty);

    expect(
          () => ds.deleteMandant(999),
      throwsA(isA<MandantException>()),
    );
  });

  test('stellt aus .bak wieder her, wenn die Hauptdatei fehlt', () async {
    final ds = await erstelleDatasource();
    await ds.createMandant(const CreateMandantRequest(nachname: 'Bein'));

    // Hauptdatei „verlieren", aber das .bak liegt noch vor (Schreibabbruch).
    final haupt = File('${tempDir.path}/mandanten.json');
    final bak = File('${tempDir.path}/mandanten.json.bak');
    await haupt.copy(bak.path);
    await haupt.delete();

    final ds2 = await erstelleDatasource();
    expect(await ds2.loadMandanten(), hasLength(1));
  });
}
