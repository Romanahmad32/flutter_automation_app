part of 'zentralruf_bloc.dart';

sealed class ZentralrufEvent {
  const ZentralrufEvent();
}

/// Lädt die Vorbelegung (laufende Auftragsnummer, Abteilung) aus den
/// Einstellungen, damit das Formular sie anzeigen kann.
final class LoadZentralrufDefaultsEvent extends ZentralrufEvent {
  const LoadZentralrufDefaultsEvent();
}

final class PrefillZentralrufFormEvent extends ZentralrufEvent {
  final ZentralrufRequest request;

  const PrefillZentralrufFormEvent({required this.request});
}

/// Bestätigt das Hochzählen der laufenden Auftragsnummer auf [neueNummer]
/// (Halbautomatik). Setzt den Wert absolut, ist also idempotent.
final class ErhoeheAuftragsnummerEvent extends ZentralrufEvent {
  final int neueNummer;

  const ErhoeheAuftragsnummerEvent(this.neueNummer);
}
