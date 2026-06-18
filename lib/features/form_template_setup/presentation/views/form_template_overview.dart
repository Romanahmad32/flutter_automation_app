import 'package:auto_route/auto_route.dart';
import 'package:automation_app/core/router/app_router.gr.dart';
import 'package:automation_app/core/theme/presentation/soft_tone.dart';
import 'package:automation_app/features/form_template_setup/domain/entities/form_template.dart';
import 'package:automation_app/features/form_template_setup/presentation/blocs/form_template_overview_bloc/form_template_overview_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Flex-Gewichte der Spalten. Header und Zeilen teilen sich dieselben Werte,
/// damit die Spalten exakt untereinander stehen und die Tabelle immer die
/// volle Breite fuellt (kein horizontales Scrollen / Abschneiden).
const int _flexName = 5;
const int _flexFiles = 4;
const int _flexFields = 2;
const double _actionsWidth = 112;

/// Spaltenindizes fuer die Sortierung.
const int _colName = 0;
const int _colFiles = 1;
const int _colFields = 2;

/// Anzahl der hinterlegten Word-Dateien (0–2) — Sortierschluessel der Spalte
/// „Dateien".
int _fileCount(FormTemplate t) =>
    (t.hasOhneAuflistung ? 1 : 0) + (t.hasMitAuflistung ? 1 : 0);

class FormTemplateOverview extends StatelessWidget {
  final FormTemplateOverviewLoaded state;

  const FormTemplateOverview({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Keine einzige Vorlage angelegt -> reiner Leerzustand ohne Suchleiste.
    if (state.formTemplates.isEmpty) {
      return _buildEmptyState(context);
    }

    final filtered = state.filteredTemplates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchBar(initialQuery: state.query),
        const SizedBox(height: 12),
        Expanded(
          child: filtered.isEmpty
              ? _buildNoResultsState(context)
              : _TemplateTable(templates: filtered),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _resultLabel(filtered.length),
            style: Theme
                .of(context)
                .textTheme
                .labelMedium
                ?.copyWith(
              color: Theme
                  .of(context)
                  .colorScheme
                  .outline,
            ),
          ),
        ),
      ],
    );
  }

  String _resultLabel(int count) {
    final noun = count == 1 ? 'Vorlage' : 'Vorlagen';
    if (state.query
        .trim()
        .isEmpty) return '$count $noun';
    return '$count von ${state.formTemplates.length} $noun';
  }

  Widget _buildNoResultsState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'Keine Vorlage passt zu „${state.query}".',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Noch keine Vorlagen gespeichert',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Legen Sie über "Neue Vorlage erstellen" Ihre erste Vorlage an.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// Flex-basierte Tabelle mit sortierbaren Spaltenkoepfen. Bewusst kein
/// [DataTable]: dessen Spalten lassen sich nicht flexibel auf die volle Breite
/// verteilen (und der Sortierpfeil schiebt Spalten aus dem Bild). Die Sortierung
/// ist lokaler Widget-State und liegt nicht im geteilten Singleton-Bloc.
class _TemplateTable extends StatefulWidget {
  final List<FormTemplate> templates;

  const _TemplateTable({required this.templates});

  @override
  State<_TemplateTable> createState() => _TemplateTableState();
}

class _TemplateTableState extends State<_TemplateTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;

  void _onSort(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
    });
  }

  List<FormTemplate> get _sortedTemplates {
    final list = [...widget.templates];
    final index = _sortColumnIndex;
    if (index == null) return list;

    int compare(FormTemplate a, FormTemplate b) {
      switch (index) {
        case _colName:
          return a.templateName.toLowerCase().compareTo(
            b.templateName.toLowerCase(),
          );
        case _colFiles:
          return _fileCount(a).compareTo(_fileCount(b));
        case _colFields:
          return a.fields.length.compareTo(b.fields.length);
        default:
          return 0;
      }
    }

    list.sort((a, b) => _sortAscending ? compare(a, b) : compare(b, a));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = _sortedTemplates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(theme),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
            itemBuilder: (context, index) =>
                _TemplateRow(template: sorted[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final style = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Row(
      children: [
        _headerCell('Vorlage', _colName, style, flex: _flexName),
        _headerCell('Dateien', _colFiles, style, flex: _flexFiles),
        _headerCell('Felder', _colFields, style, flex: _flexFields),
        // Aktionen ist nicht sortierbar.
        SizedBox(
          width: _actionsWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text('Aktionen', style: style, textAlign: TextAlign.end),
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String label,
      int columnIndex,
      TextStyle? style, {
        required int flex,
      }) {
    final active = _sortColumnIndex == columnIndex;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => _onSort(columnIndex),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                active
                    ? (_sortAscending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward)
                    : Icons.unfold_more,
                size: 16,
                color: active
                    ? Theme
                    .of(context)
                    .colorScheme
                    .primary
                    : Theme
                    .of(context)
                    .colorScheme
                    .outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateRow extends StatelessWidget {
  final FormTemplate template;

  const _TemplateRow({required this.template});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fieldCount = template.fields.length;
    final requiredCount = template.fields
        .where((f) => f.required)
        .length;

    return InkWell(
      onTap: () => _navigateToDetails(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            // Vorlage
            Expanded(
              flex: _flexName,
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      template.templateName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Dateien
            Expanded(
              flex: _flexFiles,
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (template.hasOhneAuflistung)
                    _AuflistungBadge(
                      label: 'ohne Auflistung',
                      accent: scheme.tertiary,
                    ),
                  if (template.hasMitAuflistung)
                    _AuflistungBadge(
                      label: 'mit Auflistung',
                      accent: scheme.primary,
                    ),
                  if (!template.hasOhneAuflistung && !template.hasMitAuflistung)
                    _AuflistungBadge(
                      label: 'keine Datei',
                      accent: scheme.error,
                    ),
                ],
              ),
            ),
            // Felder
            Expanded(
              flex: _flexFields,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$fieldCount ${fieldCount == 1 ? 'Feld' : 'Felder'}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (requiredCount > 0)
                    Text(
                      'davon $requiredCount Pflicht',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            // Aktionen
            SizedBox(
              width: _actionsWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => _navigateToDetails(context),
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Vorlage bearbeiten',
                  ),
                  IconButton(
                    onPressed: () => _showDeleteDialog(context, template.id),
                    icon: const Icon(Icons.delete_outline),
                    color: scheme.error,
                    tooltip: 'Vorlage löschen',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToDetails(BuildContext context) async {
    final didChange = await context.router.push<bool>(
      FormTemplateDetailsRoute(formTemplate: template),
    );
    if (didChange == true && context.mounted) {
      context.read<FormTemplateOverviewBloc>().add(LoadFormTemplatesEvent());
    }
  }

  void _showDeleteDialog(BuildContext context, int templateId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_rounded,
            size: 40,
            color: Theme
                .of(context)
                .colorScheme
                .error,
          ),
          title: const Text('Löschen bestätigen'),
          content: const Text(
            'Soll die Vorlage wirklich gelöscht werden? Diese Aktion kann nicht rückgängig gemacht werden.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              // UX: Destructive action clearly marked with error colors
              style: FilledButton.styleFrom(
                backgroundColor: Theme
                    .of(context)
                    .colorScheme
                    .error,
                foregroundColor: Theme
                    .of(context)
                    .colorScheme
                    .onError,
              ),
              onPressed: () {
                context.read<FormTemplateOverviewBloc>().add(
                  DeleteFormTemplateEvent(templateId: templateId),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );
  }
}

/// Suchfeld mit eigenem Controller. Owned-State verhindert Cursor-Spruenge,
/// die ein vom Bloc gesteuerter Text verursachen wuerde; gefiltert wird ueber
/// den Bloc per [SearchFormTemplatesEvent].
class _SearchBar extends StatefulWidget {
  final String initialQuery;

  const _SearchBar({required this.initialQuery});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dispatch(String value) {
    context.read<FormTemplateOverviewBloc>().add(
      SearchFormTemplatesEvent(query: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _dispatch,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Vorlagen nach Name oder Feld durchsuchen …',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        border: const OutlineInputBorder(),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Suche zurücksetzen',
              onPressed: () {
                _controller.clear();
                _dispatch('');
              },
            );
          },
        ),
      ),
    );
  }
}

/// Dezenter Badge, der anzeigt, welche Auflistungs-Version hinterlegt ist.
/// Nutzt [SoftTone], damit der Hintergrund im Light-Mode hell getoent bleibt
/// (statt der fast schwarzen `*Container`-Farben des Themes).
class _AuflistungBadge extends StatelessWidget {
  final String label;
  final Color accent;

  const _AuflistungBadge({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    final tone = SoftTone.fromAccent(accent, Theme
        .of(context)
        .colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tone.border),
      ),
      child: Text(
        label,
        style: Theme
            .of(context)
            .textTheme
            .labelSmall
            ?.copyWith(
          color: tone.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
