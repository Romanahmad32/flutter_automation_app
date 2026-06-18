import 'package:equatable/equatable.dart';

/// Eine gestartete Zentralruf-Anfrage, deren Antwort noch aussteht. Wird beim
/// Vorausfüllen des Anfrageformulars protokolliert, damit eine eingehende
/// Antwort über die Referenz dem richtigen Vorgang zugeordnet werden kann
/// (Req. 3.3).
class OffeneAnfrage extends Equatable {
  final String referenz;
  final DateTime angefragtAm;

  const OffeneAnfrage({required this.referenz, required this.angefragtAm});

  factory OffeneAnfrage.fromJson(Map<String, dynamic> json) => OffeneAnfrage(
    referenz: json['referenz'] as String,
    angefragtAm: DateTime.parse(json['angefragtAm'] as String),
  );

  Map<String, dynamic> toJson() => {
    'referenz': referenz,
    'angefragtAm': angefragtAm.toIso8601String(),
  };

  @override
  List<Object?> get props => [referenz, angefragtAm];
}
