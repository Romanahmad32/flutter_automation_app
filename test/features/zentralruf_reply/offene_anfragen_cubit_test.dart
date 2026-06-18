import 'package:automation_app/features/zentralruf_reply/data/datasources/local_vorgaenge_datasource.dart';
import 'package:automation_app/features/zentralruf_reply/domain/entities/offene_anfrage.dart';
import 'package:automation_app/features/zentralruf_reply/domain/entities/zentralruf_reply_data.dart';
import 'package:automation_app/features/zentralruf_reply/presentation/blocs/offene_anfragen_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-Memory-Ersatz für die Datei-Persistenz.
class _FakeVorgaengeDatasource implements LocalVorgaengeDatasource {
  ZentralrufReplyData? vorgangsdaten;
  List<OffeneAnfrage> offeneAnfragen = const [];

  @override
  Future<ZentralrufReplyData?> loadVorgangsdaten() async => vorgangsdaten;

  @override
  Future<void> saveVorgangsdaten(ZentralrufReplyData? data) async =>
      vorgangsdaten = data;

  @override
  Future<List<OffeneAnfrage>> loadOffeneAnfragen() async => offeneAnfragen;

  @override
  Future<void> saveOffeneAnfragen(List<OffeneAnfrage> anfragen) async =>
      offeneAnfragen = anfragen;
}

void main() {
  late _FakeVorgaengeDatasource datasource;
  late OffeneAnfragenCubit cubit;

  setUp(() {
    datasource = _FakeVorgaengeDatasource();
    cubit = OffeneAnfragenCubit(datasource);
  });

  tearDown(() => cubit.close());

  test('registriere legt offene Anfrage an und persistiert sie', () async {
    await cubit.registriere('84/26 C03_GG-CK 321');

    expect(cubit.state, hasLength(1));
    expect(cubit.state.single.referenz, '84/26 C03_GG-CK 321');
    expect(datasource.offeneAnfragen, hasLength(1));
  });

  test('gleiche Referenz wird nicht doppelt geführt', () async {
    await cubit.registriere('84/26 C03_GG-CK 321');
    await cubit.registriere('84/26 C03_GG-CK 321');

    expect(cubit.state, hasLength(1));
  });

  test(
    'findeZuReferenz ist tolerant bei Schreibweise und Whitespace',
    () async {
      await cubit.registriere('84/26 C03_GG-CK 321');

      expect(cubit.findeZuReferenz('84/26  c03_gg-ck 321 '), isNotNull);
      expect(cubit.findeZuReferenz('85/26 C03_GG-CK 321'), isNull);
      expect(cubit.findeZuReferenz(null), isNull);
    },
  );

  test('beantwortet entfernt die Anfrage aus Liste und Persistenz', () async {
    await cubit.registriere('84/26 C03_GG-CK 321');
    await cubit.beantwortet('84/26 C03_GG-CK 321');

    expect(cubit.state, isEmpty);
    expect(datasource.offeneAnfragen, isEmpty);
  });

  test('stellt persistierte Anfragen beim Erzeugen wieder her', () async {
    datasource.offeneAnfragen = [
      OffeneAnfrage(
        referenz: '12/26 C03_HG-E 1427',
        angefragtAm: DateTime(2026, 6, 1),
      ),
    ];

    final restored = OffeneAnfragenCubit(datasource);
    // _restore läuft asynchron im Konstruktor an.
    await Future<void>.delayed(Duration.zero);

    expect(restored.state, hasLength(1));
    expect(restored.findeZuReferenz('12/26 C03_HG-E 1427'), isNotNull);
    await restored.close();
  });
}
