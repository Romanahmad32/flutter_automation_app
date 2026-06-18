import 'package:automation_app/features/zentralruf_reply/data/datasources/local_vorgaenge_datasource.dart';
import 'package:automation_app/features/zentralruf_reply/domain/entities/offene_anfrage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Protokoll der gestarteten Zentralruf-Anfragen, deren Antwort noch
/// aussteht. Eine eingehende Antwort wird über ihre Referenz gegen diese
/// Liste abgeglichen ("dem richtigen Vorgang zuordnen", Req. 3.3); mit der
/// Übernahme der Antwortdaten gilt die Anfrage als beantwortet.
@lazySingleton
class OffeneAnfragenCubit extends Cubit<List<OffeneAnfrage>> {
  final LocalVorgaengeDatasource _datasource;

  OffeneAnfragenCubit(this._datasource) : super(const []) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      emit(await _datasource.loadOffeneAnfragen());
    } catch (_) {
      // Best-effort: ohne Persistenz bleibt die Liste leer.
    }
  }

  /// Beim Vorausfüllen des Anfrageformulars aufgerufen. Gleiche Referenz
  /// erneut angefragt → Zeitstempel aktualisieren statt doppelt führen.
  Future<void> registriere(String referenz) async {
    final bereinigt = referenz.trim();
    if (bereinigt.isEmpty) return;
    final neu = [
      ...state.where(
        (anfrage) => !_gleicheReferenz(anfrage.referenz, bereinigt),
      ),
      OffeneAnfrage(referenz: bereinigt, angefragtAm: DateTime.now()),
    ];
    emit(neu);
    try {
      await _datasource.saveOffeneAnfragen(neu);
    } catch (_) {}
  }

  /// Markiert die Anfrage als beantwortet (z. B. nach Übernahme der Antwort).
  Future<void> beantwortet(String referenz) async {
    final neu = state
        .where((anfrage) => !_gleicheReferenz(anfrage.referenz, referenz))
        .toList();
    if (neu.length == state.length) return;
    emit(neu);
    try {
      await _datasource.saveOffeneAnfragen(neu);
    } catch (_) {}
  }

  /// Liefert die offene Anfrage zur Referenz einer Antwortmail, falls vorhanden.
  OffeneAnfrage? findeZuReferenz(String? referenz) {
    if (referenz == null || referenz.trim().isEmpty) return null;
    for (final anfrage in state) {
      if (_gleicheReferenz(anfrage.referenz, referenz)) return anfrage;
    }
    return null;
  }

  /// Referenzvergleich tolerant gegenüber Groß-/Kleinschreibung und
  /// Mehrfach-Leerzeichen (Mailprogramme brechen Zeilen gern um).
  static bool _gleicheReferenz(String a, String b) =>
      _normalize(a) == _normalize(b);

  static String _normalize(String referenz) =>
      referenz.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
}
