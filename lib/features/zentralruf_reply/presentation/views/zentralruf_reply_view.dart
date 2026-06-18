import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:automation_app/core/di/injection.dart';
import 'package:automation_app/core/general_widgets/buttons/custom_rectangular_button.dart';
import 'package:automation_app/core/theme/presentation/soft_tone.dart';
import 'package:automation_app/features/zentralruf_reply/domain/entities/offene_anfrage.dart';
import 'package:automation_app/features/zentralruf_reply/domain/entities/zentralruf_reply_data.dart';
import 'package:automation_app/features/zentralruf_reply/presentation/blocs/offene_anfragen_cubit.dart';
import 'package:automation_app/features/zentralruf_reply/presentation/blocs/vorgangsdaten_cubit.dart';
import 'package:automation_app/features/zentralruf_reply/presentation/blocs/zentralruf_reply_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ZentralrufReplyView extends StatefulWidget {
  const ZentralrufReplyView({super.key});

  @override
  State<ZentralrufReplyView> createState() => _ZentralrufReplyViewState();
}

class _ZentralrufReplyViewState extends State<ZentralrufReplyView> {
  final _emailTextController = TextEditingController();

  /// Geladene .eml-Datei (Base64): wird unverändert ans Backend gegeben,
  /// das die MIME-Kodierung (Quoted-Printable, Base64, HTML) auflöst.
  String? _emlBase64;
  String? _emlFileName;

  @override
  void dispose() {
    _emailTextController.dispose();
    super.dispose();
  }

  Future<void> _loadFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Zentralruf-Antwort laden',
      type: FileType.custom,
      allowedExtensions: ['txt', 'eml'],
    );
    final file = result?.files.single;
    final path = file?.path;
    if (file == null || path == null) return;

    final bytes = await File(path).readAsBytes();
    if (path.toLowerCase().endsWith('.eml')) {
      setState(() {
        _emlBase64 = base64Encode(bytes);
        _emlFileName = file.name;
        _emailTextController.clear();
      });
      return;
    }

    // .txt: UTF-8 zuerst, Windows-Dateien sind aber oft Latin-1/ANSI.
    String text;
    try {
      text = utf8.decode(bytes);
    } on FormatException {
      text = latin1.decode(bytes);
    }
    setState(() {
      _emlBase64 = null;
      _emlFileName = null;
      _emailTextController.text = text;
    });
  }

  Future<void> _pasteFromClipboard() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboard?.text case final text? when text.trim().isNotEmpty) {
      setState(() {
        _emlBase64 = null;
        _emlFileName = null;
        _emailTextController.text = text;
      });
    }
  }

  void _extract() {
    final ZentralrufReplyInput input;
    if (_emlBase64 case final eml?) {
      input = ZentralrufReplyInput.emlBase64(eml);
    } else {
      final text = _emailTextController.text;
      if (text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bitte zuerst den E-Mail-Text einfügen oder eine Datei laden.',
            ),
          ),
        );
        return;
      }
      input = ZentralrufReplyInput.text(text);
    }
    context.read<ZentralrufReplyBloc>().add(ParseZentralrufReplyEvent(input));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ZentralrufReplyBloc>().state;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Linke Seite: E-Mail-Text einfügen oder laden.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Antwortmail des Zentralrufs',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Fügen Sie den vollständigen Text der Antwortmail ein oder '
                  'laden Sie sie als Datei (.txt oder .eml). Die App '
                  'extrahiert daraus die Daten der gegnerischen Versicherung.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                if (_emlFileName case final fileName?) ...[
                  InputChip(
                    avatar: const Icon(Icons.mail_outline),
                    label: Text(fileName),
                    onDeleted: () => setState(() {
                      _emlBase64 = null;
                      _emlFileName = null;
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
                Expanded(
                  child: TextField(
                    controller: _emailTextController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (_) {
                      // Manuelle Eingabe ersetzt eine geladene .eml-Datei.
                      if (_emlBase64 != null) {
                        setState(() {
                          _emlBase64 = null;
                          _emlFileName = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: _emlFileName == null
                          ? 'E-Mail-Text hier einfügen …'
                          : 'Die geladene .eml-Datei wird ausgewertet.',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _loadFromFile,
                      icon: const Icon(Icons.file_open),
                      label: const Text('Aus Datei laden'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(Icons.paste),
                      label: const Text('Aus Zwischenablage'),
                    ),
                    const Spacer(),
                    CustomRectangularButton(
                      label: state is ZentralrufReplyLoading
                          ? const Text('Wird ausgewertet …')
                          : const Text('Daten extrahieren'),
                      onPressed: state is ZentralrufReplyLoading
                          ? null
                          : _extract,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        // Rechte Seite: extrahierte Daten prüfen, korrigieren und übernehmen.
        SizedBox(
          width: 480,
          child: switch (state) {
            ZentralrufReplyParsed(result: final result) => _ParsedDataPanel(
              // Neuer Parse → Formular mit den neuen Werten neu aufbauen.
              key: ObjectKey(result),
              result: result,
            ),
            ZentralrufReplyError(message: final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
            _ => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Noch keine Daten extrahiert.\n'
                  'Links die Antwortmail einfügen und auf '
                  '"Daten extrahieren" klicken.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          },
        ),
      ],
    );
  }
}

/// Editierbares Formular mit den extrahierten Werten: der Anwalt kann fehlende
/// oder falsch erkannte Angaben direkt hier korrigieren, bevor sie in den
/// Vorgang übernommen werden (statt später in der Vorlage abzutippen).
class _ParsedDataPanel extends StatefulWidget {
  final ZentralrufReplyParseResult result;

  const _ParsedDataPanel({super.key, required this.result});

  @override
  State<_ParsedDataPanel> createState() => _ParsedDataPanelState();
}

class _ParsedDataPanelState extends State<_ParsedDataPanel> {
  late final Map<_Feld, TextEditingController> _controllers;

  ZentralrufReplyData get _data => widget.result.data;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final feld in _Feld.values)
        feld: TextEditingController(text: feld.wert(_data) ?? ''),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _wertVon(_Feld feld) {
    final text = _controllers[feld]!.text.trim();
    return text.isEmpty ? null : text;
  }

  ZentralrufReplyData _bearbeiteteDaten() {
    final referenz = _wertVon(_Feld.referenz);
    // Die zerlegten Referenz-Bestandteile stammen aus dem Parser; wurde die
    // Referenz von Hand geändert, passen sie nicht mehr und entfallen.
    final referenzUnveraendert = referenz == _data.referenz;
    return ZentralrufReplyData(
      referenz: referenz,
      referenzAuftragsnummer: referenzUnveraendert
          ? _data.referenzAuftragsnummer
          : null,
      referenzJahr: referenzUnveraendert ? _data.referenzJahr : null,
      referenzAbteilung: referenzUnveraendert ? _data.referenzAbteilung : null,
      referenzKennzeichen: referenzUnveraendert
          ? _data.referenzKennzeichen
          : null,
      anfrageDatum: _wertVon(_Feld.anfrageDatum),
      kennzeichen: _wertVon(_Feld.kennzeichen),
      unfallDatum: _wertVon(_Feld.unfallDatum),
      versichererName: _wertVon(_Feld.versichererName),
      versichererStrasse: _wertVon(_Feld.versichererStrasse),
      versichererPlz: _wertVon(_Feld.versichererPlz),
      versichererOrt: _wertVon(_Feld.versichererOrt),
      versichererTelefon: _wertVon(_Feld.versichererTelefon),
      versichererFax: _wertVon(_Feld.versichererFax),
      versichererEmail: _wertVon(_Feld.versichererEmail),
      versicherungsscheinNr: _wertVon(_Feld.versicherungsscheinNr),
      versicherungsbeginn: _wertVon(_Feld.versicherungsbeginn),
      keinVersichererErmittelt: _data.keinVersichererErmittelt,
    );
  }

  void _uebernehmen() {
    final daten = _bearbeiteteDaten();
    getIt<VorgangsdatenCubit>().uebernehmen(daten);
    // Die zugehörige Anfrage gilt mit der Übernahme als beantwortet.
    if (daten.referenz case final referenz?) {
      getIt<OffeneAnfragenCubit>().beantwortet(referenz);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Vorgangsdaten übernommen und gespeichert. Passende Felder werden '
          'beim Ausfüllen der Vorlage automatisch vorbelegt.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
    // Direkt weiter zu "Word Vorlagen ausfüllen". Reihenfolge der Tabs siehe
    // AppShellPage: 0 Anfrage, 1 Antwort, 2 Postfach, 3 Word Automation.
    AutoTabsRouter.of(context).setActiveIndex(3);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keinVersicherer = _data.keinVersichererErmittelt;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Extrahierte Vorgangsdaten', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Bitte prüfen und bei Bedarf direkt hier korrigieren.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _ZuordnungHinweis(referenz: _data.referenz),
          if (keinVersicherer)
            Builder(
              builder: (context) {
                final tone = SoftTone.fromAccent(
                  theme.colorScheme.error,
                  theme.colorScheme,
                );
                return Card(
                  color: tone.background,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Der Zentralruf konnte zu dieser Anfrage keinen Versicherer '
                      'ermitteln. Bitte Kennzeichen und Unfalldatum prüfen und '
                      'die Anfrage ggf. wiederholen.',
                      style: TextStyle(color: tone.foreground),
                    ),
                  ),
                );
              },
            ),
          for (final warnung in widget.result.warnings)
            if (!keinVersicherer || !warnung.contains('keinen Versicherer'))
              Builder(
                builder: (context) {
                  final tone = SoftTone.fromAccent(
                    theme.colorScheme.tertiary,
                    theme.colorScheme,
                  );
                  return Card(
                    color: tone.background,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: tone.foreground),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              warnung,
                              style: TextStyle(color: tone.foreground),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          const SizedBox(height: 8),
          for (final feld in _Feld.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: _controllers[feld],
                decoration: InputDecoration(
                  labelText: feld.label,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  // Nicht erkannte Pflichtangaben deutlich markieren.
                  helperText: feld.wert(_data) == null
                      ? 'nicht gefunden'
                      : null,
                  helperStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          CustomRectangularButton(
            icon: const Icon(Icons.check),
            label: const Text('Übernehmen und Vorlage ausfüllen'),
            onPressed: keinVersicherer ? null : _uebernehmen,
          ),
        ],
      ),
    );
  }
}

/// Zeigt, ob die Antwort über ihre Referenz einer zuvor gestarteten
/// Zentralruf-Anfrage zugeordnet werden konnte (Req. 3.3).
class _ZuordnungHinweis extends StatelessWidget {
  final String? referenz;

  const _ZuordnungHinweis({required this.referenz});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<OffeneAnfragenCubit, List<OffeneAnfrage>>(
      bloc: getIt<OffeneAnfragenCubit>(),
      builder: (context, offeneAnfragen) {
        final cubit = getIt<OffeneAnfragenCubit>();
        final anfrage = cubit.findeZuReferenz(referenz);
        if (anfrage != null) {
          final datum = anfrage.angefragtAm;
          final datumText =
              '${datum.day.toString().padLeft(2, '0')}.'
              '${datum.month.toString().padLeft(2, '0')}.${datum.year}';
          final tone = SoftTone.fromAccent(
            theme.colorScheme.primary,
            theme.colorScheme,
          );
          return Card(
            color: tone.background,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.link, color: tone.foreground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Zugeordnet zur Zentralruf-Anfrage vom $datumText '
                      '(Referenz ${anfrage.referenz}).',
                      style: TextStyle(color: tone.foreground),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (offeneAnfragen.isEmpty || referenz == null) {
          return const SizedBox.shrink();
        }

        final tone = SoftTone.fromAccent(
          theme.colorScheme.tertiary,
          theme.colorScheme,
        );
        return Card(
          color: tone.background,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Zur Referenz "$referenz" ist keine offene Zentralruf-Anfrage '
              'bekannt — bitte prüfen, ob die Antwort zum richtigen Vorgang '
              'gehört.',
              style: TextStyle(color: tone.foreground),
            ),
          ),
        );
      },
    );
  }
}

/// Die editierbaren Felder des Antwort-Formulars in Anzeigereihenfolge.
enum _Feld {
  referenz('Referenz (Ihr Zeichen)'),
  anfrageDatum('Anfrage vom'),
  kennzeichen('Gegnerisches Kennzeichen'),
  unfallDatum('Unfalldatum'),
  versichererName('Versicherer'),
  versichererStrasse('Straße'),
  versichererPlz('PLZ'),
  versichererOrt('Ort'),
  versichererTelefon('Telefon'),
  versichererFax('Fax'),
  versichererEmail('E-Mail'),
  versicherungsscheinNr('Versicherungsschein-Nr.'),
  versicherungsbeginn('Versicherungsbeginn');

  final String label;

  const _Feld(this.label);

  String? wert(ZentralrufReplyData data) => switch (this) {
    _Feld.referenz => data.referenz,
    _Feld.anfrageDatum => data.anfrageDatum,
    _Feld.kennzeichen => data.kennzeichen,
    _Feld.unfallDatum => data.unfallDatum,
    _Feld.versichererName => data.versichererName,
    _Feld.versichererStrasse => data.versichererStrasse,
    _Feld.versichererPlz => data.versichererPlz,
    _Feld.versichererOrt => data.versichererOrt,
    _Feld.versichererTelefon => data.versichererTelefon,
    _Feld.versichererFax => data.versichererFax,
    _Feld.versichererEmail => data.versichererEmail,
    _Feld.versicherungsscheinNr => data.versicherungsscheinNr,
    _Feld.versicherungsbeginn => data.versicherungsbeginn,
  };
}
