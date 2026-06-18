part of 'zentralruf_bloc.dart';

sealed class ZentralrufState extends Equatable {
  const ZentralrufState();

  @override
  List<Object> get props => [];
}

final class ZentralrufInitial extends ZentralrufState {}

final class ZentralrufLoading extends ZentralrufState {}

/// Vorbelegung des Formulars aus den Einstellungen (laufende Auftragsnummer und
/// Abteilung). Wird beim Öffnen der Seite und nach jeder Erhöhung der
/// Auftragsnummer emittiert, damit das Formular den aktuellen Wert anzeigt.
final class ZentralrufDefaultsLoaded extends ZentralrufState {
  final int auftragsnummer;
  final String abteilung;

  const ZentralrufDefaultsLoaded({
    required this.auftragsnummer,
    required this.abteilung,
  });

  @override
  List<Object> get props => [auftragsnummer, abteilung];
}

final class ZentralrufPrefillSuccess extends ZentralrufState {
  final ZentralrufPrefillResult result;

  /// Im Halbautomatik-Modus gesetzt: die vorgeschlagene nächste Auftragsnummer,
  /// die der Anwalt per Aktion bestätigen kann. Null, wenn kein Vorschlag ansteht.
  final int? auftragsnummerVorschlag;

  /// Im Automatik-Modus gesetzt: die Auftragsnummer wurde bereits auf diesen
  /// Wert erhöht und gespeichert. Null, wenn nicht automatisch erhöht wurde.
  final int? auftragsnummerErhoehtAuf;

  const ZentralrufPrefillSuccess(
    this.result, {
    this.auftragsnummerVorschlag,
    this.auftragsnummerErhoehtAuf,
  });

  @override
  List<Object> get props => [
    result.referenz,
    auftragsnummerVorschlag ?? -1,
    auftragsnummerErhoehtAuf ?? -1,
  ];
}

/// Die laufende Auftragsnummer wurde (nach Bestätigung) auf [neueNummer] erhöht.
final class ZentralrufAuftragsnummerErhoeht extends ZentralrufState {
  final int neueNummer;

  const ZentralrufAuftragsnummerErhoeht(this.neueNummer);

  @override
  List<Object> get props => [neueNummer];
}

final class ZentralrufError extends ZentralrufState {
  final String message;

  const ZentralrufError(this.message);

  @override
  List<Object> get props => [message];
}
