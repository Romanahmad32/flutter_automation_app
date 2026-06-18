import 'package:automation_app/features/word_automation/domain/entities/damage_listing.dart';
import 'package:automation_app/features/word_automation/presentation/blocs/rvg_calculation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Live-Vorschau der Schadensaufstellung im Dokument-Look: Positionen,
/// Zwischensumme (lokal summiert) und die vom Backend berechneten
/// RVG-Anwaltskosten. Spiegelt das Layout der generierten Word-Tabelle wider.
class SchadensaufstellungPreview extends StatelessWidget {
  final DamageListing? damageListing;

  const SchadensaufstellungPreview({super.key, required this.damageListing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rvgState = context.watch<RvgCalculationBloc>().state;

    final items = damageListing?.items ?? const <DamageItem>[];
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Noch keine vollständige Schadensposition erfasst.\n'
          'Bezeichnung und Betrag eingeben, um die Vorschau zu sehen.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final zwischensumme = items.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    final headerStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );
    // Konfigurierte Titelzeilen-Farbe (aus den Einstellungen); Fallback ist das
    // Standardgrau des Backends, damit die Vorschau dem Dokument entspricht.
    // Die Farben sind hell, daher in der Kopfzeile dunkle Schrift erzwingen.
    final headerColor =
        _parseHex(damageListing?.headerColorHex) ?? const Color(0xFFD9D9D9);
    final headerCellStyle = headerStyle?.copyWith(color: Colors.black87);
    final bandedColor = headerColor.withValues(alpha: 0.4);
    final thickLine = BorderSide(color: theme.colorScheme.onSurface, width: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Table(
            border: TableBorder.all(color: theme.dividerColor),
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: headerColor),
                children: [
                  _cell('Position', style: headerCellStyle),
                  _cell('Bezeichnung', style: headerCellStyle),
                  _cell(
                    'Forderung in €',
                    style: headerCellStyle,
                    alignRight: true,
                  ),
                ],
              ),
              for (final (index, item) in items.indexed)
                TableRow(
                  decoration: index.isOdd
                      ? BoxDecoration(color: bandedColor)
                      : null,
                  children: [
                    _cell('${index + 1}'),
                    _cell(item.description),
                    _cell(_euro(item.amount), alignRight: true),
                  ],
                ),
              // Leerzeile wie im generierten Dokument.
              const TableRow(children: [_Cell(''), _Cell(''), _Cell('')]),
              TableRow(
                decoration: BoxDecoration(
                  border: Border(top: thickLine, bottom: thickLine),
                ),
                children: [
                  _cell(''),
                  _cell('Zwischensumme (ohne RA-Kosten)', style: headerStyle),
                  _cell(
                    _euro(zwischensumme),
                    style: headerStyle,
                    alignRight: true,
                  ),
                ],
              ),
              TableRow(
                children: [
                  _cell(''),
                  _cell('Anwaltskosten nach RVG'),
                  _rvgBruttoCell(rvgState),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RvgDetails(
            rvgState: rvgState,
            zwischensumme: zwischensumme,
            damageListing: damageListing,
          ),
        ],
      ),
    );
  }

  static Color? _parseHex(String? hex) {
    final value = hex?.trim().replaceFirst('#', '') ?? '';
    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(value)) return null;
    return Color(0xFF000000 | int.parse(value, radix: 16));
  }

  Widget _cell(String text, {TextStyle? style, bool alignRight = false}) =>
      _Cell(text, style: style, alignRight: alignRight);

  Widget _rvgBruttoCell(RvgCalculationState rvgState) {
    return switch (rvgState) {
      RvgCalculationLoaded(:final calculation) => _Cell(
        _euro(calculation.brutto),
        alignRight: true,
      ),
      RvgCalculationLoading() => const Padding(
        padding: EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      RvgCalculationError() => const _Cell('—', alignRight: true),
      RvgCalculationInitial() => const _Cell('…', alignRight: true),
    };
  }

  static String _euro(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final digits = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return '$buffer,${parts[1]}';
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool alignRight;

  const _Cell(this.text, {this.style, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        text,
        style: style,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
      ),
    );
  }
}

/// Vollständige Aufschlüsselung der RVG-Berechnung unterhalb der Tabelle:
/// jeder Rechenschritt mit seiner gesetzlichen Grundlage, damit die Berechnung
/// gegen die amtliche Gebührentabelle (Anlage 2 zu § 13 RVG) geprüft werden
/// kann. Manuell korrigierte Werte sind entsprechend gekennzeichnet.
class _RvgDetails extends StatelessWidget {
  final RvgCalculationState rvgState;
  final double zwischensumme;
  final DamageListing? damageListing;

  const _RvgDetails({
    required this.rvgState,
    required this.zwischensumme,
    required this.damageListing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (rvgState) {
      case RvgCalculationError(:final message):
        return Text(
          'RVG-Berechnung fehlgeschlagen: $message',
          style: TextStyle(color: theme.colorScheme.error),
        );
      case RvgCalculationLoaded(:final calculation):
        final geschaeftsgebuehrKorrigiert =
            damageListing?.geschaeftsgebuehrOverride != null;
        final auslagenKorrigiert =
            damageListing?.auslagenpauschaleOverride != null;
        final rows = <(String, String, double, bool)>[
          (
            'Gegenstandswert',
            'Summe der Schadenspositionen',
            calculation.gegenstandswert,
            false,
          ),
          (
            'Wertgebühr (1,0)',
            'Anlage 2 zu § 13 RVG (amtliche Gebührentabelle)',
            calculation.wertgebuehr,
            false,
          ),
          (
            'Geschäftsgebühr',
            geschaeftsgebuehrKorrigiert
                ? 'manuell korrigiert — statt '
                      '${SchadensaufstellungPreview._euro(calculation.wertgebuehr)} € '
                      '× ${_satz(calculation.gebuehrensatz)} (Nr. 2300 VV RVG)'
                : 'Wertgebühr × ${_satz(calculation.gebuehrensatz)} (Nr. 2300 VV RVG)',
            calculation.geschaeftsgebuehr,
            geschaeftsgebuehrKorrigiert,
          ),
          (
            'Auslagenpauschale',
            auslagenKorrigiert
                ? 'manuell korrigiert — statt 20 % der Geschäftsgebühr, '
                      'max. 20 € (Nr. 7002 VV RVG)'
                : '20 % der Geschäftsgebühr, max. 20 € (Nr. 7002 VV RVG)',
            calculation.auslagenpauschale,
            auslagenKorrigiert,
          ),
          ('Zwischensumme RA-Kosten (netto)', '', calculation.netto, false),
          if (calculation.umsatzsteuer > 0)
            (
              'Umsatzsteuer (19 %)',
              'Nr. 7008 VV RVG',
              calculation.umsatzsteuer,
              false,
            ),
          ('Anwaltskosten gesamt', '', calculation.brutto, false),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'RVG-Berechnung im Detail',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            for (final (label, basis, value, korrigiert) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label),
                          if (basis.isNotEmpty)
                            Text(
                              basis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: korrigiert
                                    ? theme.colorScheme.tertiary
                                    : theme.colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${SchadensaufstellungPreview._euro(value)} €',
                      style: korrigiert
                          ? TextStyle(
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.tertiary,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Gesamtforderung (inkl. RA-Kosten)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${SchadensaufstellungPreview._euro(zwischensumme + calculation.brutto)} €',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Referenz: amtliche Gebührentabelle, Anlage 2 zu § 13 RVG '
              '(Stand KostBRÄG 2025, ab 01.06.2025).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  static String _satz(double value) {
    final text = value.toStringAsFixed(2).replaceAll('.', ',');
    return text.endsWith('0') ? text.substring(0, text.length - 1) : text;
  }
}
