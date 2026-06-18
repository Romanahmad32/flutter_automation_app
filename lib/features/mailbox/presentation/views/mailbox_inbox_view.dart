import 'package:auto_route/auto_route.dart';
import 'package:automation_app/core/di/injection.dart';
import 'package:automation_app/core/theme/presentation/soft_tone.dart';
import 'package:automation_app/features/mailbox/domain/entities/mailbox_status.dart';
import 'package:automation_app/features/mailbox/domain/entities/received_reply.dart';
import 'package:automation_app/features/mailbox/presentation/blocs/mailbox_inbox_cubit/mailbox_inbox_cubit.dart';
import 'package:automation_app/features/zentralruf_reply/domain/entities/zentralruf_reply_data.dart';
import 'package:automation_app/features/zentralruf_reply/presentation/blocs/offene_anfragen_cubit.dart';
import 'package:automation_app/features/zentralruf_reply/presentation/blocs/vorgangsdaten_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Reihenfolge der Tabs siehe AppShellPage: Word Automation liegt auf Index 3.
const int _wordAutomationTabIndex = 3;

/// Inbox-Ansicht der automatisch erfassten Zentralruf-Antworten: oben der
/// Verbindungsstatus der Überwachung, darunter links die Trefferliste und rechts
/// die Detailansicht mit "Daten übernehmen" (füllt den Vorgang ohne Abtippen)
/// und "Erledigt".
class MailboxInboxView extends StatefulWidget {
  const MailboxInboxView({super.key});

  @override
  State<MailboxInboxView> createState() => _MailboxInboxViewState();
}

class _MailboxInboxViewState extends State<MailboxInboxView> {
  String? _selectedId;

  void _uebernehmen(ReceivedReply reply) {
    getIt<VorgangsdatenCubit>().uebernehmen(reply.data);
    if (reply.data.referenz case final referenz?) {
      getIt<OffeneAnfragenCubit>().beantwortet(referenz);
    }
    // Mit der Übernahme gilt der Treffer als erledigt.
    context.read<MailboxInboxCubit>().acknowledge(reply.id);
    setState(() => _selectedId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Vorgangsdaten übernommen. Passende Felder werden beim Ausfüllen der '
          'Vorlage automatisch vorbelegt.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
    AutoTabsRouter.of(context).setActiveIndex(_wordAutomationTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MailboxInboxCubit, MailboxInboxState>(
      builder: (context, state) {
        final replies = state.replies;
        final selected = replies
            .where((reply) => reply.id == _selectedId)
            .firstOrNull;

        return Column(
          children: [
            _StatusBanner(status: state.status, error: state.error),
            const Divider(height: 1),
            Expanded(
              child: state.loading && replies.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : replies.isEmpty
                  ? _EmptyHint(status: state.status)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 360,
                          child: _ReplyList(
                            replies: replies,
                            selectedId: _selectedId,
                            onSelect: (id) => setState(() => _selectedId = id),
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: selected == null
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                      'Eine Antwort links auswählen, um die '
                                      'erkannten Daten zu sehen.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : _ReplyDetail(
                                  key: ValueKey(selected.id),
                                  reply: selected,
                                  onUebernehmen: () => _uebernehmen(selected),
                                  onErledigt: () {
                                    context
                                        .read<MailboxInboxCubit>()
                                        .acknowledge(selected.id);
                                    setState(() => _selectedId = null);
                                  },
                                ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Statuszeile: verbunden / inaktiv / Fehler, plus letzter Empfang.
class _StatusBanner extends StatelessWidget {
  final MailboxStatus status;
  final String? error;

  const _StatusBanner({required this.status, required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (Color accent, IconData icon, String text) = switch (status) {
      _ when error != null => (
        theme.colorScheme.error,
        Icons.error_outline,
        error!,
      ),
      MailboxStatus(connected: true) => (
        Colors.green,
        Icons.cloud_done,
        'Verbunden — eingehende Antworten werden automatisch erfasst'
            '${status.idleSupported ? ' (Push/IDLE)' : ' (Abruf-Modus)'}.',
      ),
      MailboxStatus(enabled: false) => (
        theme.colorScheme.outline,
        Icons.cloud_off,
        'Überwachung ausgeschaltet. In den Einstellungen unter '
            '"Postfach-Zugang" aktivieren.',
      ),
      MailboxStatus(configured: false) => (
        theme.colorScheme.tertiary,
        Icons.key_off,
        'Kein Postfach-Zugang hinterlegt. In den Einstellungen unter '
            '"Postfach-Zugang" einrichten.',
      ),
      _ when status.lastError != null => (
        theme.colorScheme.error,
        Icons.sync_problem,
        'Verbindung unterbrochen: ${status.lastError}. Es wird automatisch '
            'erneut verbunden.',
      ),
      _ => (
        theme.colorScheme.tertiary,
        Icons.sync,
        'Überwachung eingeschaltet — verbinde …',
      ),
    };

    final tone = SoftTone.fromAccent(accent, theme.colorScheme);
    return Container(
      width: double.infinity,
      color: tone.background,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: tone.foreground, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: tone.foreground)),
          ),
          if (status.lastReplyAt case final last?) ...[
            const SizedBox(width: 12),
            Text(
              'Letzter Empfang: ${_formatDateTime(last)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: tone.foreground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final MailboxStatus status;

  const _EmptyHint({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              status.connected
                  ? 'Noch keine offenen Antworten. Neue Zentralruf-Mails '
                        'erscheinen hier automatisch.'
                  : 'Sobald ein Postfach-Zugang hinterlegt und die Überwachung '
                        'aktiv ist, erscheinen eingehende Antworten hier.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyList extends StatelessWidget {
  final List<ReceivedReply> replies;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _ReplyList({
    required this.replies,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      itemCount: replies.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final reply = replies[index];
        final data = reply.data;
        final hatWarnung =
            reply.warnings.isNotEmpty || data.keinVersichererErmittelt;
        return ListTile(
          selected: reply.id == selectedId,
          selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.08),
          leading: Icon(
            hatWarnung ? Icons.warning_amber : Icons.mark_email_unread,
            color: hatWarnung ? theme.colorScheme.tertiary : null,
          ),
          title: Text(
            data.referenz ?? data.versichererName ?? '(ohne Referenz)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${data.versichererName ?? 'Versicherer unbekannt'}'
            ' · ${_formatDateTime(reply.receivedAt)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => onSelect(reply.id),
        );
      },
    );
  }
}

class _ReplyDetail extends StatelessWidget {
  final ReceivedReply reply;
  final VoidCallback onUebernehmen;
  final VoidCallback onErledigt;

  const _ReplyDetail({
    super.key,
    required this.reply,
    required this.onUebernehmen,
    required this.onErledigt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = reply.data;
    final keinVersicherer = data.keinVersichererErmittelt;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Erfasste Antwort', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          if (reply.subject case final subject?)
            Text(subject, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          if (keinVersicherer)
            _ToneCard(
              accent: theme.colorScheme.error,
              icon: Icons.report_gmailerrorred,
              text:
                  'Der Zentralruf konnte zu dieser Anfrage keinen Versicherer '
                  'ermitteln. Kennzeichen und Unfalldatum prüfen und die Anfrage '
                  'ggf. wiederholen.',
            ),
          for (final warnung in reply.warnings)
            if (!keinVersicherer || !warnung.contains('keinen Versicherer'))
              _ToneCard(
                accent: theme.colorScheme.tertiary,
                icon: Icons.warning_amber,
                text: warnung,
              ),
          const SizedBox(height: 8),
          for (final (label, value) in _felder(data))
            _DatenZeile(label: label, value: value),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.download_done),
            label: const Text('Daten übernehmen und Vorlage ausfüllen'),
            onPressed: keinVersicherer ? null : onUebernehmen,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Als erledigt markieren'),
            onPressed: onErledigt,
          ),
        ],
      ),
    );
  }

  static List<(String, String?)> _felder(ZentralrufReplyData data) => [
    ('Referenz (Ihr Zeichen)', data.referenz),
    ('Anfrage vom', data.anfrageDatum),
    ('Gegnerisches Kennzeichen', data.kennzeichen),
    ('Unfalldatum', data.unfallDatum),
    ('Versicherer', data.versichererName),
    ('Straße', data.versichererStrasse),
    ('PLZ', data.versichererPlz),
    ('Ort', data.versichererOrt),
    ('Telefon', data.versichererTelefon),
    ('Fax', data.versichererFax),
    ('E-Mail', data.versichererEmail),
    ('Versicherungsschein-Nr.', data.versicherungsscheinNr),
    ('Versicherungsbeginn', data.versicherungsbeginn),
  ];
}

class _DatenZeile extends StatelessWidget {
  final String label;
  final String? value;

  const _DatenZeile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fehlt = value == null || value!.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              fehlt ? 'nicht gefunden' : value!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: fehlt ? FontStyle.italic : null,
                color: fehlt ? theme.colorScheme.error : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToneCard extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String text;

  const _ToneCard({
    required this.accent,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final tone = SoftTone.fromAccent(accent, Theme.of(context).colorScheme);
    return Card(
      color: tone.background,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: tone.foreground),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: TextStyle(color: tone.foreground)),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.day)}.${two(value.month)}.${value.year} '
      '${two(value.hour)}:${two(value.minute)}';
}
