import 'dart:io';

import 'package:automation_app/core/di/injection.dart';
import 'package:automation_app/core/general_widgets/buttons/custom_rectangular_button.dart';
import 'package:automation_app/core/general_widgets/buttons/dropdowns/template_selector.dart';
import 'package:automation_app/core/theme/presentation/soft_tone.dart';
import 'package:automation_app/features/form_template_setup/presentation/blocs/form_template_overview_bloc/form_template_overview_bloc.dart';
import 'package:automation_app/features/word_automation/presentation/blocs/document_bloc.dart';
import 'package:automation_app/features/word_automation/presentation/blocs/edited_document_bloc.dart';
import 'package:automation_app/features/word_automation/presentation/blocs/pdf_preview_bloc.dart';
import 'package:automation_app/features/word_automation/presentation/blocs/wizard_cubit.dart';
import 'package:automation_app/features/word_automation/presentation/utils/formular_extraktion.dart';
import 'package:automation_app/features/word_automation/presentation/widgets/form_template_builder.dart';
import 'package:automation_app/features/word_automation/presentation/widgets/generation_overlay.dart';
import 'package:automation_app/features/word_automation/presentation/widgets/pdf_preview_view.dart';
import 'package:automation_app/features/zentralruf_reply/domain/entities/zentralruf_reply_data.dart';
import 'package:automation_app/features/zentralruf_reply/domain/services/vorgangsdaten_field_matcher.dart';
import 'package:automation_app/features/zentralruf_reply/presentation/blocs/vorgangsdaten_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../form_template_setup/domain/entities/form_template.dart';

/// Schritt 1: Formularvorlage wählen, Auflistungs-Version und
/// Vorsteuer-Status festlegen, Felder ausfüllen und das Dokument erzeugen
/// lassen. Rechts durchgehend die originalgetreue PDF-Vorschau der Vorlage.
class WizardStepFillOut extends StatelessWidget {
  const WizardStepFillOut({super.key});

  void _onTemplateSelected(BuildContext context, FormTemplate? template) {
    context.read<WizardCubit>().selectFormTemplate(template);
    _loadActiveWordFile(context);
  }

  /// Lädt die zur aktuellen Auswahl (ohne/mit Auflistung) passende Word-Datei.
  void _loadActiveWordFile(BuildContext context) {
    final path = context.read<WizardCubit>().state.activeWordFilePath;
    if (path == null) {
      return;
    }
    if (File(path).existsSync()) {
      context.read<DocumentBloc>().add(SetDocumentPathEvent(path));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Die verknüpfte Word-Datei wurde nicht gefunden:\n$path\n'
            'Bitte wählen Sie die Datei neu aus.',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _onMitAuflistungChanged(BuildContext context, bool value) {
    final cubit = context.read<WizardCubit>();
    final template = cubit.state.selectedFormTemplate;
    if (template == null) {
      return;
    }
    final targetPath = value
        ? template.wordFilePathMitAuflistung
        : template.wordFilePathOhneAuflistung;
    if (targetPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Für diese Vorlage ist keine Version mit Auflistung hinterlegt. '
                      'Bitte im Vorlagen-Management eine Datei mit Auflistung '
                      'verknüpfen.'
                : 'Für diese Vorlage ist keine Version ohne Auflistung '
                      'hinterlegt. Bitte im Vorlagen-Management eine Datei ohne '
                      'Auflistung verknüpfen.',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }
    cubit.setMitAuflistung(value);
    _loadActiveWordFile(context);
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = context.watch<WizardCubit>().state;
    final documentState = context.watch<DocumentBloc>().state;
    final isGenerating =
        context.watch<EditedDocumentBloc>().state is EditedDocumentLoading;

    final selectedTemplate = wizardState.selectedFormTemplate;
    final loadedPath = documentState is DocumentLoaded
        ? documentState.path
        : null;

    return BlocListener<DocumentBloc, DocumentState>(
      listenWhen: (previous, current) =>
          current is DocumentLoaded && previous != current,
      listener: (context, state) async {
        // Manuell gewählte Datei dauerhaft am aktiven Slot der Vorlage
        // hinterlegen (no-op, wenn der Pfad bereits hinterlegt ist). Die
        // Vorlagenliste NUR dann neu laden, wenn tatsächlich eine neue
        // Verknüpfung gespeichert wurde: Ein Neuladen bei jeder Auswahl stößt
        // im TemplateSelector ein Resync an, das die gerade getroffene Auswahl
        // (Formular, Dateiname, PDF) wieder auf die vorherige zurücksetzen kann.
        final path = (state as DocumentLoaded).path;
        final overviewBloc = context.read<FormTemplateOverviewBloc>();
        final linked = await context.read<WizardCubit>().linkWordFileToTemplate(
          path,
        );
        if (linked && !overviewBloc.isClosed) {
          overviewBloc.add(LoadFormTemplatesEvent());
        }
      },
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TemplateSelector(
                        value: selectedTemplate,
                        onChanged: (value) =>
                            _onTemplateSelected(context, value),
                      ),
                      const SizedBox(height: 16),
                      if (selectedTemplate != null) ...[
                        _OptionsCard(
                          template: selectedTemplate,
                          mitAuflistung: wizardState.mitAuflistung,
                          vorsteuerabzugsberechtigt:
                              wizardState.vorsteuerabzugsberechtigt,
                          onMitAuflistungChanged: (value) =>
                              _onMitAuflistungChanged(context, value),
                          onVorsteuerChanged: (value) => context
                              .read<WizardCubit>()
                              .setVorsteuerabzugsberechtigt(value),
                        ),
                        const SizedBox(height: 16),
                        _WordFileRow(loadedPath: loadedPath),
                        const SizedBox(height: 16),
                        if (loadedPath != null)
                          // Übernommene Zentralruf-Antwortdaten (falls
                          // vorhanden) auf die Vorlagenfelder mappen und
                          // sichtbar vorbelegen (Req. 3.3 → 3.4).
                          BlocBuilder<VorgangsdatenCubit, ZentralrufReplyData?>(
                            bloc: getIt<VorgangsdatenCubit>(),
                            builder: (context, vorgangsdaten) {
                              final prefill = vorgangsdaten == null
                                  ? const <String, String>{}
                                  : VorgangsdatenFieldMatcher.matchFields(
                                      selectedTemplate.fields.map(
                                        (field) => field.label,
                                      ),
                                      vorgangsdaten,
                                    );
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (prefill.isNotEmpty)
                                    _VorgangsdatenHinweis(
                                      anzahlFelder: prefill.length,
                                    ),
                                  FormTemplateBuilder(
                                    formTemplate: selectedTemplate,
                                    initialValues: prefill,
                                    submitButtonLabel: Text(
                                      wizardState.mitAuflistung
                                          ? 'Weiter zur Schadensaufstellung'
                                          : 'Dokument erstellen',
                                    ),
                                    onSubmitted: (formData) {
                                      final cubit = context.read<WizardCubit>();
                                      cubit.setFormData(formData);
                                      if (cubit.state.mitAuflistung) {
                                        // Generierung erst am Ende des
                                        // Schadensaufstellungs-Schritts.
                                        cubit.goToStep(
                                          WizardStep.schadensaufstellung,
                                        );
                                      } else {
                                        final datum = ursachendatumAusFormular(
                                          selectedTemplate.fields,
                                          formData,
                                        );
                                        context.read<EditedDocumentBloc>().add(
                                          EditDocumentEvent(
                                            data: formData,
                                            damageListing: null,
                                            path: loadedPath,
                                            vorsteuerabzugsberechtigt: cubit
                                                .state
                                                .vorsteuerabzugsberechtigt,
                                            outputFileName: baueDateiname(
                                              loadedPath,
                                              datum,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                      ] else
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Bitte zuerst eine Formularvorlage auswählen.',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: PdfPreviewView(
                  bloc: context.read<TemplatePdfPreviewBloc>(),
                  emptyHint: 'Keine Word-Datei geladen',
                ),
              ),
            ],
          ),
          if (isGenerating) const GenerationOverlay(),
        ],
      ),
    );
  }
}

/// Auswahl der Auflistungs-Version und des Vorsteuer-Status für die aktuelle
/// Vorlage.
class _OptionsCard extends StatelessWidget {
  final FormTemplate template;
  final bool mitAuflistung;
  final bool vorsteuerabzugsberechtigt;
  final ValueChanged<bool> onMitAuflistungChanged;
  final ValueChanged<bool> onVorsteuerChanged;

  const _OptionsCard({
    required this.template,
    required this.mitAuflistung,
    required this.vorsteuerabzugsberechtigt,
    required this.onMitAuflistungChanged,
    required this.onVorsteuerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final versionHinweis = !template.hasMitAuflistung
        ? 'Keine Version mit Auflistung hinterlegt.'
        : !template.hasOhneAuflistung
        ? 'Nur eine Version mit Auflistung hinterlegt.'
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: const Text('Mit Auflistung (Schadensaufstellung)'),
              subtitle: Text(
                versionHinweis ??
                    'Fügt einen Schritt für Schadenspositionen und die '
                        'RVG-Kostenberechnung hinzu.',
                style: versionHinweis != null
                    ? TextStyle(color: theme.colorScheme.error)
                    : null,
              ),
              value: mitAuflistung,
              onChanged: (value) => onMitAuflistungChanged(value ?? false),
            ),
            CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: const Text('Mandant ist vorsteuerabzugsberechtigt'),
              subtitle: const Text(
                'Kreuzt im Dokument "ist / ist nicht vorsteuerabzugsberechtigt" '
                'an und steuert die RVG-Umsatzsteuer.',
              ),
              value: vorsteuerabzugsberechtigt,
              onChanged: (value) => onVorsteuerChanged(value ?? false),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hinweis, dass Felder aus der übernommenen Zentralruf-Antwort vorbelegt
/// wurden (sichtbar und änderbar — keine stille Befüllung).
class _VorgangsdatenHinweis extends StatelessWidget {
  final int anzahlFelder;

  const _VorgangsdatenHinweis({required this.anzahlFelder});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Dezenter, getoenter Hinweis statt der im Light-Mode fast schwarzen
    // secondaryContainer-Farbe.
    final tone = SoftTone.fromAccent(colorScheme.primary, colorScheme);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: tone.background,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.mark_email_read, color: tone.foreground),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                anzahlFelder == 1
                    ? '1 Feld wurde aus der Zentralruf-Antwort vorbelegt.'
                    : '$anzahlFelder Felder wurden aus der Zentralruf-Antwort '
                          'vorbelegt.',
                style: TextStyle(color: tone.foreground),
              ),
            ),
            TextButton(
              onPressed: () => getIt<VorgangsdatenCubit>().verwerfen(),
              child: const Text('Verwerfen'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Zeigt die geladene Word-Datei bzw. bietet an, eine zu wählen, wenn der
/// aktive Slot noch keine (gültige) Verknüpfung hat.
class _WordFileRow extends StatelessWidget {
  final String? loadedPath;

  const _WordFileRow({this.loadedPath});

  @override
  Widget build(BuildContext context) {
    if (loadedPath == null) {
      return CustomRectangularButton(
        onPressed: () =>
            context.read<DocumentBloc>().add(const SelectDocumentEvent()),
        icon: const Icon(Icons.file_open),
        label: const Text('Word-Datei wählen'),
      );
    }

    return Row(
      children: [
        const Icon(Icons.description, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            loadedPath!.split(RegExp(r'[\\/]')).last,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: () =>
              context.read<DocumentBloc>().add(const SelectDocumentEvent()),
          child: const Text('Andere Datei …'),
        ),
      ],
    );
  }
}
