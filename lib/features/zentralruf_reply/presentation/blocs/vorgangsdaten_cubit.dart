import 'package:automation_app/features/zentralruf_reply/data/datasources/local_vorgaenge_datasource.dart';
import 'package:automation_app/features/zentralruf_reply/domain/entities/zentralruf_reply_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// App-weiter Speicher für die aus der Zentralruf-Antwort übernommenen
/// Vorgangsdaten (Anforderung 3.3). Wird lokal persistiert und beim Start
/// wiederhergestellt — die Antwort des Zentralrufs kommt oft erst Tage nach
/// der Anfrage, ein App-Neustart darf die Daten nicht verlieren.
@lazySingleton
class VorgangsdatenCubit extends Cubit<ZentralrufReplyData?> {
  final LocalVorgaengeDatasource _datasource;

  VorgangsdatenCubit(this._datasource) : super(null) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final stored = await _datasource.loadVorgangsdaten();
      // Nur setzen, wenn nicht inzwischen schon neue Daten übernommen wurden.
      if (state == null && stored != null) emit(stored);
    } catch (_) {
      // Wiederherstellung ist best-effort; ohne Persistenz startet die
      // Sitzung einfach leer.
    }
  }

  Future<void> uebernehmen(ZentralrufReplyData data) async {
    emit(data);
    try {
      await _datasource.saveVorgangsdaten(data);
    } catch (_) {}
  }

  Future<void> verwerfen() async {
    emit(null);
    try {
      await _datasource.saveVorgangsdaten(null);
    } catch (_) {}
  }
}
