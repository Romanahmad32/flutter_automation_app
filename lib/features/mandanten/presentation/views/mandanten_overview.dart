import 'package:auto_route/auto_route.dart';
import 'package:automation_app/core/router/app_router.gr.dart';
import 'package:automation_app/features/mandanten/domain/entities/akte.dart';
import 'package:automation_app/features/mandanten/domain/entities/mandant.dart';
import 'package:automation_app/features/mandanten/presentation/blocs/mandanten_overview_bloc/mandanten_overview_bloc.dart';
import 'package:automation_app/features/mandanten/presentation/utils/ordnername_vorschlag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MandantenOverview extends StatelessWidget {
  final MandantenOverviewLoaded state;

  const MandantenOverview({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.mandanten.isEmpty && state.akten.isEmpty) {
      return _LeererZustand();
    }

    final gefiltert = state.gefilterteMandanten;
    final nichtZugeordnet = state.nichtZugeordneteAkten;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchBar(initialQuery: state.query),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              if (nichtZugeordnet.isNotEmpty) ...[
                _NichtZugeordneteSektion(akten: nichtZugeordnet, state: state),
                const SizedBox(height: 20),
              ],
              _MandantenSektionKopf(
                anzahl: gefiltert.length,
                gesamt: state.mandanten.length,
                query: state.query,
              ),
              const SizedBox(height: 8),
              if (state.mandanten.isEmpty)
                _Hinweis(
                  'Noch keine Mandanten gespeichert. Legen Sie über „Neuer '
                  'Mandant" einen an oder ordnen Sie einen gefundenen Ordner zu.',
                )
              else if (gefiltert.isEmpty)
                _Hinweis('Kein Mandant passt zu „${state.query}".')
              else
                for (final mandant in gefiltert)
                  _MandantCard(mandant: mandant, state: state),
            ],
          ),
        ),
      ],
    );
  }
}

class _MandantenSektionKopf extends StatelessWidget {
  final int anzahl;
  final int gesamt;
  final String query;

  const _MandantenSektionKopf({
    required this.anzahl,
    required this.gesamt,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = query.trim().isEmpty
        ? '$anzahl ${anzahl == 1 ? 'Mandant' : 'Mandanten'}'
        : '$anzahl von $gesamt Mandanten';
    return Row(
      children: [
        Icon(
          Icons.people_alt_outlined,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'Mandanten',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _MandantCard extends StatelessWidget {
  final Mandant mandant;
  final MandantenOverviewLoaded state;

  const _MandantCard({required this.mandant, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final akten = state.aktenFuer(mandant);
    final fallAnzahl = akten.fold<int>(0, (sum, a) => sum + a.faelle.length);
    final adresse = [
      mandant.strasseHausnummer,
      [mandant.postleitzahl, mandant.ort].where((e) => e.isNotEmpty).join(' '),
    ].where((e) => e.trim().isNotEmpty).join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Text(
            _initialen(mandant),
            style: TextStyle(color: scheme.onPrimaryContainer),
          ),
        ),
        title: Text(
          mandant.anzeigename.isEmpty ? '(ohne Namen)' : mandant.anzeigename,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          adresse.isEmpty ? 'Keine Adresse hinterlegt' : adresse,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Row(
            children: [
              _InfoChip(
                icon: Icons.folder_outlined,
                label:
                    '${akten.length} ${akten.length == 1 ? 'Akte' : 'Akten'}',
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.description_outlined,
                label: '$fallAnzahl ${fallAnzahl == 1 ? 'Fall' : 'Fälle'}',
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _bearbeiten(context),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Mandant bearbeiten',
              ),
              IconButton(
                onPressed: () => _loeschen(context),
                icon: const Icon(Icons.delete_outline),
                color: scheme.error,
                tooltip: 'Mandant löschen',
              ),
            ],
          ),
          if (akten.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Noch keine Akte zugeordnet.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                ),
              ),
            )
          else
            for (final akte in akten) _AkteBlock(akte: akte),
        ],
      ),
    );
  }

  String _initialen(Mandant m) {
    final v = m.vorname.isNotEmpty ? m.vorname[0] : '';
    final n = m.nachname.isNotEmpty ? m.nachname[0] : '';
    final s = '$v$n'.toUpperCase();
    return s.isEmpty ? '?' : s;
  }

  Future<void> _bearbeiten(BuildContext context) async {
    final bloc = context.read<MandantenOverviewBloc>();
    final didChange = await context.router.push<bool>(
      MandantDetailsRoute(mandant: mandant),
    );
    if (didChange == true) {
      bloc.add(LoadMandantenUebersichtEvent());
    }
  }

  void _loeschen(BuildContext context) {
    final bloc = context.read<MandantenOverviewBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.warning_rounded,
          size: 40,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('Löschen bestätigen'),
        content: Text(
          'Soll der Mandant „${mandant.anzeigename}" aus der App entfernt '
          'werden? Die Akten-Ordner im Dateisystem bleiben unberührt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              bloc.add(DeleteMandantEvent(mandant.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}

class _AkteBlock extends StatelessWidget {
  final Akte akte;

  const _AkteBlock({required this.akte});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder, size: 18, color: theme.colorScheme.tertiary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  akte.ordnername,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          for (final fall in akte.faelle)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 2),
              child: Text(
                '• ${fall.name}'
                '${fall.dokumente.isEmpty ? '' : '  (${fall.dokumente.length})'}',
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

/// Sektion mit gefundenen Ordnern, die noch keinem Mandanten zugeordnet sind.
class _NichtZugeordneteSektion extends StatelessWidget {
  final List<Akte> akten;
  final MandantenOverviewLoaded state;

  const _NichtZugeordneteSektion({required this.akten, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rule_folder_outlined,
                size: 20,
                color: scheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Nicht zugeordnete Ordner (${akten.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Im Stammordner gefundene Ordner ohne Mandanten-Zuordnung. Ordnen '
            'Sie jeden einem bestehenden oder neuen Mandanten zu.',
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: 8),
          for (final akte in akten)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.folder_off_outlined, color: scheme.outline),
              title: Text(akte.ordnername),
              subtitle: Text(
                '${akte.faelle.length} ${akte.faelle.length == 1 ? 'Fall' : 'Fälle'}',
              ),
              trailing: FilledButton.tonalIcon(
                onPressed: () => _zuordnen(context, akte),
                icon: const Icon(Icons.link, size: 18),
                label: const Text('Zuordnen'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _zuordnen(BuildContext context, Akte akte) async {
    final bloc = context.read<MandantenOverviewBloc>();
    final router = context.router;
    final auswahl = await showDialog<_ZuordnenErgebnis>(
      context: context,
      builder: (_) => _ZuordnenDialog(
        ordnername: akte.ordnername,
        mandanten: state.mandanten,
      ),
    );
    if (auswahl == null) return;

    if (auswahl.neuerMandant) {
      final vorschlag = nameVorschlagAusOrdner(akte.ordnername);
      final didChange = await router.push<bool>(
        MandantDetailsRoute(
          vorbelegterOrdner: akte.ordnername,
          vorbelegterVorname: vorschlag.vorname,
          vorbelegterNachname: vorschlag.nachname,
        ),
      );
      if (didChange == true) bloc.add(LoadMandantenUebersichtEvent());
    } else {
      bloc.add(
        VerknuepfeOrdnerEvent(
          mandantId: auswahl.mandantId!,
          ordnername: akte.ordnername,
        ),
      );
    }
  }
}

class _ZuordnenErgebnis {
  final bool neuerMandant;
  final int? mandantId;

  const _ZuordnenErgebnis.neu() : neuerMandant = true, mandantId = null;

  const _ZuordnenErgebnis.bestehend(this.mandantId) : neuerMandant = false;
}

/// Dialog: gefundenen Ordner einem bestehenden Mandanten zuordnen oder einen
/// neuen anlegen.
class _ZuordnenDialog extends StatelessWidget {
  final String ordnername;
  final List<Mandant> mandanten;

  const _ZuordnenDialog({required this.ordnername, required this.mandanten});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ordner zuordnen'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ordner: „$ordnername"'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pop(context, const _ZuordnenErgebnis.neu()),
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Neuen Mandanten anlegen'),
            ),
            const SizedBox(height: 12),
            if (mandanten.isNotEmpty) ...[
              const Divider(),
              Text(
                'oder bestehendem Mandanten zuordnen:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final m in mandanten)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.person_outline),
                        title: Text(
                          m.anzeigename.isEmpty
                              ? '(ohne Namen)'
                              : m.anzeigename,
                        ),
                        onTap: () => Navigator.pop(
                          context,
                          _ZuordnenErgebnis.bestehend(m.id),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _Hinweis extends StatelessWidget {
  final String text;

  const _Hinweis(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}

class _LeererZustand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Noch keine Mandanten und keine Akten gefunden',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Legen Sie über „Neuer Mandant" einen Mandanten an oder hinterlegen '
            'Sie in den Einstellungen den Stammordner des Aktensystems.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// Suchfeld mit eigenem Controller (verhindert Cursor-Sprünge); filtert über
/// den Bloc per [SearchMandantenEvent].
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
    context.read<MandantenOverviewBloc>().add(SearchMandantenEvent(value));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _dispatch,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Mandanten nach Name, Ort oder Ordner durchsuchen …',
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
