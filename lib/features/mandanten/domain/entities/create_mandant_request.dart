import 'package:equatable/equatable.dart';

/// Eingabedaten zum Anlegen eines neuen Mandanten. Die `id` und `erstelltAm`
/// vergibt das Register beim Speichern (analog zu CreateFormTemplateRequest).
class CreateMandantRequest extends Equatable {
  final String vorname;
  final String nachname;
  final String strasseHausnummer;
  final String postleitzahl;
  final String ort;
  final String emailAdresse;
  final String telefonnummer;
  final String notiz;

  /// Optional: ein bereits vorhandener Akten-Ordner, der dem neuen Mandanten
  /// direkt zugeordnet wird (manuelle Zuordnung beim Anlegen).
  final List<String> aktenOrdnernamen;

  const CreateMandantRequest({
    this.vorname = '',
    this.nachname = '',
    this.strasseHausnummer = '',
    this.postleitzahl = '',
    this.ort = '',
    this.emailAdresse = '',
    this.telefonnummer = '',
    this.notiz = '',
    this.aktenOrdnernamen = const [],
  });

  @override
  List<Object?> get props => [
    vorname,
    nachname,
    strasseHausnummer,
    postleitzahl,
    ort,
    emailAdresse,
    telefonnummer,
    notiz,
    aktenOrdnernamen,
  ];
}
