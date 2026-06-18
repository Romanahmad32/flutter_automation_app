import 'package:auto_route/auto_route.dart';
import 'package:automation_app/core/di/injection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:automation_app/core/general_widgets/buttons/custom_rectangular_button.dart';
import 'package:automation_app/features/form_template_setup/domain/entities/field_data.dart';
import 'package:automation_app/features/form_template_setup/domain/entities/form_template.dart';
import 'package:automation_app/features/form_template_setup/domain/entities/input_type.dart';
import 'package:automation_app/features/form_template_setup/presentation/blocs/form_template_data_bloc/form_template_data_bloc.dart';
import 'package:automation_app/features/form_template_setup/presentation/blocs/template_placeholders_bloc/template_placeholders_bloc.dart';
import 'package:automation_app/features/form_template_setup/presentation/widgets/form_template_action_buttons.dart';
import 'package:automation_app/features/form_template_setup/presentation/widgets/template_placeholders_view.dart';
import 'package:automation_app/features/form_template_setup/presentation/widgets/tamplate_fields_table_header.dart';
import 'package:automation_app/features/form_template_setup/presentation/widgets/template_field_item.dart';
import 'package:automation_app/features/form_template_setup/presentation/widgets/template_name_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

@RoutePage()
class FormTemplateDetailsPage extends StatefulWidget
    implements AutoRouteWrapper {
  final FormTemplate? formTemplate; // Null = Create mode, Provided = Edit mode

  const FormTemplateDetailsPage({super.key, this.formTemplate});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<FormTemplateDataBloc>()),
        BlocProvider(create: (context) => getIt<TemplatePlaceholdersBloc>()),
      ],
      child: this,
    );
  }

  @override
  State<FormTemplateDetailsPage> createState() =>
      _FormTemplateDetailsPageState();
}

class _FormTemplateDetailsPageState extends State<FormTemplateDetailsPage> {
  List<FieldData> fields = [];
  late FormGroup formGroup;
  String? _wordFilePathOhne;
  String? _wordFilePathMit;
  int _nextFieldIndex = 0;

  // Zuletzt je Slot angezeigte Fehlermeldung, um Snackbar-Wiederholungen
  // bei jedem Rebuild zu vermeiden.
  final Map<TemplateFileSlot, String?> _lastErrorShown = {};

  // Helper getter to determine the current mode
  bool get isEditing => widget.formTemplate != null;

  @override
  void initState() {
    super.initState();
    _wordFilePathOhne = widget.formTemplate?.wordFilePathOhneAuflistung;
    _wordFilePathMit = widget.formTemplate?.wordFilePathMitAuflistung;

    Map<String, AbstractControl<dynamic>> controls = {
      'templateName': FormControl<String>(
        value: isEditing ? widget.formTemplate!.templateName : null,
        validators: [Validators.required],
      ),
    };

    // 2. Pre-fill existing fields if in edit mode
    if (isEditing) {
      int index = 0;
      for (var element in widget.formTemplate!.fields) {
        String fieldKey = 'field_$index';

        fields.add(
          FieldData(
            order: index,
            label: fieldKey,
            required: element.required,
            inputType: element.inputType,
          ),
        );

        controls[fieldKey] = FormControl<String>(
          value: element.label,
          validators: element.required ? [Validators.required] : [],
        );
        index++;
      }
      _nextFieldIndex = index;
    }

    formGroup = FormGroup(controls);

    // Bei bereits verknüpften Word-Dateien die Platzhalter direkt laden.
    if (_wordFilePathOhne != null) {
      context.read<TemplatePlaceholdersBloc>().add(
        LoadTemplatePlaceholders(
          _wordFilePathOhne!,
          TemplateFileSlot.ohneAuflistung,
        ),
      );
    }
    if (_wordFilePathMit != null) {
      context.read<TemplatePlaceholdersBloc>().add(
        LoadTemplatePlaceholders(
          _wordFilePathMit!,
          TemplateFileSlot.mitAuflistung,
        ),
      );
    }
  }

  void _reorderFields(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final field = fields.removeAt(oldIndex);
      fields.insert(newIndex, field);
    });
  }

  void _addNewField({String? initialLabel}) {
    setState(() {
      final fieldKey = 'field_${_nextFieldIndex++}';
      formGroup.addAll({
        fieldKey: FormControl<String>(
          value: initialLabel,
          validators: [Validators.required],
        ),
      });
      fields.add(
        FieldData(
          order: fields.length,
          label: fieldKey,
          required: false,
          inputType: InputType.text,
        ),
      );
    });
  }

  /// Übernimmt einen erkannten Platzhalter als Eingabefeld — außer es gibt
  /// bereits ein Feld mit demselben Namen.
  void _addFieldFromPlaceholder(String placeholder) {
    final alreadyExists = fields.any((field) {
      final label = formGroup
          .control(field.label)
          .value as String?;
      return label?.trim().toLowerCase() == placeholder.toLowerCase();
    });
    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Das Feld "$placeholder" existiert bereits.')),
      );
      return;
    }
    _addNewField(initialLabel: placeholder);
  }

  Future<void> _pickFile(TemplateFileSlot slot) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );
    final path = result?.files.firstOrNull?.path;
    if (path == null || !mounted) {
      return;
    }
    setState(() {
      if (slot == TemplateFileSlot.ohneAuflistung) {
        _wordFilePathOhne = path;
      } else {
        _wordFilePathMit = path;
      }
    });
    context.read<TemplatePlaceholdersBloc>().add(
      LoadTemplatePlaceholders(path, slot),
    );
  }

  void _removeFile(TemplateFileSlot slot) {
    setState(() {
      if (slot == TemplateFileSlot.ohneAuflistung) {
        _wordFilePathOhne = null;
      } else {
        _wordFilePathMit = null;
      }
    });
    context.read<TemplatePlaceholdersBloc>().add(
      ClearTemplatePlaceholders(slot),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      // Fehler beim Lesen der Word-Datei (z. B. Datei in Word geöffnet) auch
      // als Snackbar melden, nicht nur als Inline-Text in der Platzhalter-Box.
      body: BlocListener<TemplatePlaceholdersBloc, TemplatePlaceholdersState>(
        listener: (context, state) {
          for (final slot in TemplateFileSlot.values) {
            final result = state.forSlot(slot);
            final message = result is SlotPlaceholdersError
                ? result.message
                : null;
            if (message != null && _lastErrorShown[slot] != message) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            }
            _lastErrorShown[slot] = message;
          }
        },
        child: BlocConsumer<FormTemplateDataBloc, FormTemplateDataState>(
          listener: (context, state) {
            if (state is FormTemplateDataSuccess) {
              context.router.maybePop(true);
            } else if (state is FormTemplateDataError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return ReactiveForm(
              formGroup: formGroup,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        isEditing
                            ? 'Vorlage bearbeiten'
                            : 'Neue Vorlage erstellen',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const TemplateNameCard(),

                    _buildFileSlotCard(
                      context,
                      slot: TemplateFileSlot.ohneAuflistung,
                      path: _wordFilePathOhne,
                      title: 'Vorlage ohne Auflistung (HGN)',
                      subtitle:
                      'Standardbrief mit Haftung dem Grunde nach – ohne '
                          'Schadensaufstellung.',
                    ),

                    _buildFileSlotCard(
                      context,
                      slot: TemplateFileSlot.mitAuflistung,
                      path: _wordFilePathMit,
                      title: 'Vorlage mit Auflistung (Schadensaufstellung)',
                      subtitle:
                      'Enthält {{Schadensaufstellung}}; beim Ausfüllen wird '
                          'ein zusätzlicher Schritt für die Schadenspositionen '
                          'und die RVG-Kostenberechnung angezeigt.',
                    ),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              spacing: 10,
                              children: [
                                Icon(
                                  Icons.input,
                                  color: theme.colorScheme.primaryContainer,
                                ),
                                Text(
                                  'Eingabefelder der Vorlage',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                CustomRectangularButton(
                                  icon: const Icon(Icons.add),
                                  label: const Text('Neues Feld hinzufügen'),
                                  onPressed: _addNewField,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            fields.isEmpty
                                ? const Center(
                              child: Text('Keine Felder hinzugefügt'),
                            )
                                : const TemplateFieldsTableHeader(),

                            ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              buildDefaultDragHandles: false,
                              onReorder: _reorderFields,
                              // Das gezogene Element wird in ein Overlay außerhalb
                              // des ReactiveForm gehoben — hier neu umschließen.
                              proxyDecorator: (child, index, animation) {
                                return ReactiveForm(
                                  formGroup: formGroup,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: child,
                                  ),
                                );
                              },
                              itemCount: fields.length,
                              itemBuilder: (context, index) {
                                return TemplateFieldItem(
                                  key: ValueKey(fields[index].label),
                                  index: index,
                                  fieldData: fields[index],
                                  onTypeChanged: (newValue) {
                                    setState(() {
                                      fields[index] = fields[index].copyWith(
                                        inputType: newValue,
                                      );
                                    });
                                  },
                                  onRequiredChanged: (value) {
                                    setState(() {
                                      fields[index] = fields[index].copyWith(
                                        required: value,
                                      );
                                    });
                                  },
                                  onDelete: () {
                                    setState(() {
                                      formGroup.removeControl(
                                        fields[index].label,
                                      );
                                      fields.removeAt(index);
                                    });
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FormTemplateActionButtons(
                          onCancel: () => context.router.maybePop(true),
                          fields: fields,
                          existingItemId: widget.formTemplate?.id,
                          wordFilePathOhneAuflistung: _wordFilePathOhne,
                          wordFilePathMitAuflistung: _wordFilePathMit,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Karte für eine der beiden Word-Dateien (ohne/mit Auflistung): Dateiauswahl,
  /// erkannte Platzhalter und – beim Mit-Slot – die Warnung, falls
  /// {{Schadensaufstellung}} fehlt.
  Widget _buildFileSlotCard(BuildContext context, {
    required TemplateFileSlot slot,
    required String? path,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final isMitSlot = slot == TemplateFileSlot.mitAuflistung;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(subtitle, style: theme.textTheme.bodySmall),
            Row(
              spacing: 10,
              children: [
                Icon(
                  Icons.description,
                  color: theme.colorScheme.primaryContainer,
                ),
                Expanded(
                  child: Text(
                    path ?? 'Keine Word-Datei verknüpft',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (path != null)
                  IconButton(
                    tooltip: 'Verknüpfung entfernen',
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeFile(slot),
                  ),
                CustomRectangularButton(
                  icon: const Icon(Icons.file_open),
                  label: Text(
                    path == null
                        ? 'Word-Datei verknüpfen'
                        : 'Andere Datei wählen',
                  ),
                  onPressed: () => _pickFile(slot),
                ),
              ],
            ),
            if (isMitSlot && path != null)
              BlocBuilder<TemplatePlaceholdersBloc, TemplatePlaceholdersState>(
                builder: (context, placeholdersState) {
                  final result = placeholdersState.forSlot(
                    TemplateFileSlot.mitAuflistung,
                  );
                  final missingPlaceholder =
                      result is SlotPlaceholdersLoaded &&
                          !result.placeholders.any(
                                (p) => p.toLowerCase() == 'schadensaufstellung',
                          );
                  if (!missingPlaceholder) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    spacing: 10,
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.amber),
                      Expanded(
                        child: Text(
                          'Die verknüpfte Word-Datei enthält keinen Platzhalter '
                              '{{Schadensaufstellung}}. Ohne diesen Platzhalter '
                              'schlägt die Dokumenterstellung mit Auflistung fehl.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  );
                },
              ),
            if (path != null)
              TemplatePlaceholdersView(
                slot: slot,
                onPlaceholderSelected: _addFieldFromPlaceholder,
              ),
          ],
        ),
      ),
    );
  }
}
