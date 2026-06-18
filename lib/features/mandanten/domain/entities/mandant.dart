import 'package:equatable/equatable.dart';

/// Ein Mandant der Kanzlei mit den wiederverwendbaren Stammdaten (Req. 3.1 /
/// „Daten des Kunden speichern"). Persistiert im lokalen Mandantenregister
/// (`mandanten.json`). Die Verknüpfung zur Akte im Dateisystem (§3.6) läuft
/// über [aktenOrdnernamen]: die Namen der zugeordneten Ordner unter dem
/// Stammordner. Bewusst eine Liste, weil derselbe Mandant in der echten
/// Kanzlei mehrere Sachen/Ordner haben kann (z. B. eine Straf- und eine
/// Verkehrsunfallsache).
class Mandant extends Equatable {
  final int id;
  final String vorname;
  final String nachname;
  final String strasseHausnummer;
  final String postleitzahl;
  final String ort;
  final String emailAdresse;
  final String telefonnummer;
  final String notiz;

  /// Namen der zugeordneten Akten-Ordner (relativ zum Stammordner), 0..n.
  final List<String> aktenOrdnernamen;

  /// Zeitpunkt der Anlage im Register (ISO-8601), für Sortierung/Anzeige.
  final DateTime erstelltAm;

  const Mandant({
    required this.id,
    this.vorname = '',
    this.nachname = '',
    this.strasseHausnummer = '',
    this.postleitzahl = '',
    this.ort = '',
    this.emailAdresse = '',
    this.telefonnummer = '',
    this.notiz = '',
    this.aktenOrdnernamen = const [],
    required this.erstelltAm,
  });

  /// Anzeigename „Vorname Nachname"; fällt auf das Vorhandene zurück, wenn nur
  /// eines gesetzt ist.
  String get anzeigename => '$vorname $nachname'.trim();

  factory Mandant.fromJson(Map<String, dynamic> json) {
    final ordner = json['aktenOrdnernamen'];
    return Mandant(
      id: json['id'] as int,
      vorname: json['vorname'] as String? ?? '',
      nachname: json['nachname'] as String? ?? '',
      strasseHausnummer: json['strasseHausnummer'] as String? ?? '',
      postleitzahl: json['postleitzahl'] as String? ?? '',
      ort: json['ort'] as String? ?? '',
      emailAdresse: json['emailAdresse'] as String? ?? '',
      telefonnummer: json['telefonnummer'] as String? ?? '',
      notiz: json['notiz'] as String? ?? '',
      aktenOrdnernamen: ordner is List
          ? ordner.whereType<String>().toList()
          : const [],
      erstelltAm:
          DateTime.tryParse(json['erstelltAm'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vorname': vorname,
    'nachname': nachname,
    'strasseHausnummer': strasseHausnummer,
    'postleitzahl': postleitzahl,
    'ort': ort,
    'emailAdresse': emailAdresse,
    'telefonnummer': telefonnummer,
    'notiz': notiz,
    'aktenOrdnernamen': aktenOrdnernamen,
    'erstelltAm': erstelltAm.toIso8601String(),
  };

  Mandant copyWith({
    String? vorname,
    String? nachname,
    String? strasseHausnummer,
    String? postleitzahl,
    String? ort,
    String? emailAdresse,
    String? telefonnummer,
    String? notiz,
    List<String>? aktenOrdnernamen,
  }) {
    return Mandant(
      id: id,
      vorname: vorname ?? this.vorname,
      nachname: nachname ?? this.nachname,
      strasseHausnummer: strasseHausnummer ?? this.strasseHausnummer,
      postleitzahl: postleitzahl ?? this.postleitzahl,
      ort: ort ?? this.ort,
      emailAdresse: emailAdresse ?? this.emailAdresse,
      telefonnummer: telefonnummer ?? this.telefonnummer,
      notiz: notiz ?? this.notiz,
      aktenOrdnernamen: aktenOrdnernamen ?? this.aktenOrdnernamen,
      erstelltAm: erstelltAm,
    );
  }

  @override
  List<Object?> get props => [
    id,
    vorname,
    nachname,
    strasseHausnummer,
    postleitzahl,
    ort,
    emailAdresse,
    telefonnummer,
    notiz,
    aktenOrdnernamen,
    erstelltAm,
  ];
}
